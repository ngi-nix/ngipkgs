// NOTE: This file was copied from reaction's examples and a few simple changes were made
//  - allow 10.0.0.0/8 cidr range to be banned as well for nginix demo
//  - skip sendmail action

// This file is using JSONnet, a complete configuration language based on JSON
// See https://jsonnet.org
// JSONnet is a superset of JSON, so one can write plain JSON files if wanted.
// Note that YAML is also supported, see ./example.yml

// This example configuration file is a good starting point, but you're
// strongly encouraged to take a look at the full documentation: https://reaction.ppom.me

// JSONnet functions
local ipBan(cmd) = [cmd, '-w', '-A', 'reaction', '-s', '<ip>', '-j', 'DROP'];
local ipUnban(cmd) = [cmd, '-w', '-D', 'reaction', '-s', '<ip>', '-j', 'DROP'];

// See meaning and usage of this function around L180
local banFor(time) = {
  ban4: {
    cmd: ipBan('iptables'),
    ipv4only: true,
  },
  ban6: {
    cmd: ipBan('ip6tables'),
    ipv6only: true,
  },
  unban4: {
    cmd: ipUnban('iptables'),
    after: time,
    ipv4only: true,
  },
  unban6: {
    cmd: ipUnban('ip6tables'),
    after: time,
    ipv6only: true,
  },
};

// See usage of this function around L90
// Generates a command for iptables and ip46tables
local ip46tables(arguments) = [
  ['iptables', '-w'] + arguments,
  ['ip6tables', '-w'] + arguments,
];

{
  // patterns are substitued in regexes.
  // when a filter performs an action, it replaces the found pattern
  patterns: {

    name: {
      // reaction regex syntax is defined here: https://docs.rs/regex/latest/regex/#syntax
      // common patterns have a 'regex' field
      regex: '[a-z]+',
      // patterns can ignore specific strings
      ignore: ['cecilia'],
      // patterns can also be ignored based on regexes, it will try to match the whole string detected by the pattern
      ignoreregex: [
        // ignore names starting with 'jo'
        'jo.*',
      ],
    },

    ip: {
      // patterns can have a special 'ip' type that matches both ipv4 and ipv6
      // or 'ipv4' or 'ipv6' to match only that ip version
      type: 'ip',
      ignore: ['127.0.0.1', '::1'],
      // they can also ignore whole CIDR ranges of ip
      // ignorecidr: ['10.0.0.0/8'],
      // last but not least, patterns of type ip, ipv4, ipv6 can also group their matched ips by mask
      // ipv4mask: 30
      // this means that ipv6 matches will be converted to their network part.
      ipv6mask: 64,
      // for example,"2001:db8:85a3:9de5::8a2e:370:7334" will be converted to "2001:db8:85a3:9de5::/64".
    },

    // ipv4: {
    //   type: 'ipv4',
    //   ignore: ...
    //   ipv4mask: ...
    // },

  },

  // where the state (database) must be read
  // defaults to . which means reaction's working directory.
  // The systemd service starts reaction in /var/lib/reaction.
  state_directory: '.',

  // if set to a positive number → max number of concurrent actions
  // if set to a negative number → no limit
  // if not specified or set to 0 → defaults to the number of CPUs on the system
  concurrency: 0,

  // Those commands will be executed in order at start, before everything else
  start:
    // Create an iptables chain for reaction
    ip46tables(['-N', 'reaction']) +
    // Insert this chain as the first item of the INPUT & FORWARD chains (for incoming connections)
    ip46tables(['-I', 'INPUT', '-p', 'all', '-j', 'reaction']) +
    ip46tables(['-I', 'FORWARD', '-p', 'all', '-j', 'reaction']),

  // Those commands will be executed in order at stop, after everything else
  stop:
    // Remove the chain from the INPUT & FORWARD chains
    ip46tables(['-D', 'INPUT', '-p', 'all', '-j', 'reaction']) +
    ip46tables(['-D', 'FORWARD', '-p', 'all', '-j', 'reaction']) +
    // Empty the chain
    ip46tables(['-F', 'reaction']) +
    // Delete the chain
    ip46tables(['-X', 'reaction']),


  // streams are commands
  // they are run and their ouptut is captured
  // *example:* `tail -f /var/log/nginx/access.log`
  // their output will be used by one or more filters
  streams: {
    // streams have a user-defined name
    ssh: {
      // note that if the command is not in environment's `PATH`
      // its full path must be given.
      cmd: ['journalctl', '-n0', '-fu', 'sshd.service'],

      // filters run actions when they match regexes on a stream
      filters: {
        // filters have a user-defined name
        failedlogin: {
          // reaction's regex syntax is defined here: https://docs.rs/regex/latest/regex/#syntax
          regex: [
            // <ip> is predefined in the patterns section
            // ip's regex is inserted in the following regex
            @'authentication failure;.*rhost=<ip>',
            @'Failed password for .* from <ip>',
            @'Invalid user .* from <ip>',
            @'Connection (reset|closed) by (authenticating|invalid) user .* <ip>',
            @'banner exchange: Connection from <ip> port [0-9]*: invalid format',
          ],

          // if retry and retryperiod are defined,
          // the actions will only take place if a same pattern is
          // found `retry` times in a `retryperiod` interval
          retry: 3,
          // format is defined as follows: <integer> <unit>
          // - whitespace between the integer and unit is optional
          // - integer must be positive (>= 0)
          // - unit can be one of:
          //   - ms / millis / millisecond / milliseconds
          //   - s / sec / secs / second / seconds
          //   - m / min / mins / minute / minutes
          //   - h / hour / hours
          //   - d / day / days
          retryperiod: '6h',

          // duplicate specify how to handle matches after an action has already been taken.
          // 3 options are possible:
          // - extend (default): update the pending actions' time, so they run later
          // - ignore: don't do anything, ignore the match
          // - rerun: run the actions again. so we may have the same pending actions multiple times.
          //   (this was the default before 2.2.0)
          // duplicate: extend

          // actions are run by the filter when regexes are matched
          actions: {
            // actions have a user-defined name
            ban4: {
              cmd: ['iptables', '-w', '-A', 'reaction', '-s', '<ip>', '-j', 'DROP'],
              // this optional field permits to run an action only when a pattern of type ip contains an ipv4
              ipv4only: true,
            },

            ban6: {
              cmd: ['ip6tables', '-w', '-A', 'reaction', '-s', '<ip>', '-j', 'DROP'],
              // this optional field permits to run an action only when a pattern of type ip contains an ipv6
              ipv6only: true,
            },

            unban4: {
              cmd: ['iptables', '-w', '-D', 'reaction', '-s', '<ip>', '-j', 'DROP'],
              // if after is defined, the action will not take place immediately, but after a specified duration
              // same format as retryperiod
              after: '2 days',
              // let's say reaction is quitting. does it run all those pending commands which had an `after` duration set?
              // if you want reaction to run those pending commands before exiting, you can set this:
              // onexit: true,
              // (defaults to false)
              // here it is not useful because we will flush and delete the chain containing the bans anyway
              // (with the stop commands)
              ipv4only: true,
            },

            unban6: {
              cmd: ['ip6tables', '-w', '-D', 'reaction', '-s', '<ip>', '-j', 'DROP'],
              after: '2 days',
              ipv6only: true,
            },

            /*
             mail: {
               cmd: ['sendmail', '...', '<ip>'],
               // some commands, such as alerting commands, are "oneshot".
               // this means they'll be run only once, and won't be executed again when reaction is restarted
               oneshot: true,
             },
            */
          },
          // or use the banFor function defined at the beginning!
          // actions: banFor('48h'),
        },
      },
    },
  },
}

// persistence

// tldr; when an `after` action is set in a filter, such filter acts as a 'jail',
// which is persisted after reboots.

// full;
// when a filter is triggered, there are 2 flows:
//
// if none of its actions have an `after` directive set:
// no action will be replayed.
//
// else (if at least one action has an `after` directive set):
// if reaction stops while `after` actions are pending:
// and reaction starts again while those actions would still be pending:
// reaction executes the past actions (actions without after or with then+after < now)
// and plans the execution of future actions (actions with then+after > now)

