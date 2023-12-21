# Anastasis

This flake packages [GNU Anastasis](https://anastasis.lu), a key backup and recovery tool from the GNU project.
This package includes the backend run by the Anastasis providers as well as libraries for clients and a command-line interface.

The main documentation can be found at [https://docs.taler.net/anastasis.html](https://docs.taler.net/anastasis.html).

## Server/backend

### HTTP server

```
anastasis-httpd
Anastasis HTTP interface
Arguments mandatory for long options are also mandatory for short options.
  -A, --auth=USERNAME:PASSWORD
                             use the given USERNAME and PASSWORD for client
                               authentication
  -C, --connection-close     force HTTP connections to be closed after each
                               request
  -c, --config=FILENAME      use configuration file FILENAME
  -h, --help                 print this help
  -K, --apikey=APIKEY        API key to use in the HTTP request to the
                               merchant backend
  -k, --key=KEYFILE          file with the private TLS key for TLS client
                               authentication
  -L, --log=LOGLEVEL         configure logging to use LOGLEVEL
  -l, --logfile=FILENAME     configure logging to write logs to FILENAME
  -p, --pass=KEYFILEPASSPHRASE
                             passphrase needed to decrypt the TLS client
                               private key file
  -t, --type=CERTTYPE        type of the TLS client certificate, defaults to
                               PEM if not specified
  -v, --version              print the version number
Report bugs to contact@anastasis.lu.
Home page: https://anastasis.lu/
General help using GNU software: http://www.gnu.org/gethelp/
```

### DB initialisation

```
anastasis-dbinit
Initialize anastasis database
Arguments mandatory for long options are also mandatory for short options.
  -c, --config=FILENAME      use configuration file FILENAME
  -h, --help                 print this help
  -L, --log=LOGLEVEL         configure logging to use LOGLEVEL
  -l, --logfile=FILENAME     configure logging to write logs to FILENAME
  -r, --reset                reset database (DANGEROUS: all existing data is
                               lost!)
  -v, --version              print the version number
Report bugs to contact@anastasis.lu.
Home page: https://anastasis.lu/
General help using GNU software: http://www.gnu.org/gethelp/
```

## Client CLI

Anastasis Reducer API is used by client applications to initialise, store or load the different states the client application can have.

```
anastasis-reducer
This is an application for using Anastasis to handle the states.

Arguments mandatory for long options are also mandatory for short options.
  -a, --arguments=JSON       pass a JSON string containing arguments to
                               reducer
  -b, --backup               use reducer to handle states for backup process
  -c, --config=FILENAME      use configuration file FILENAME
  -h, --help                 print this help
  -L, --log=LOGLEVEL         configure logging to use LOGLEVEL
  -l, --logfile=FILENAME     configure logging to write logs to FILENAME
  -r, --restore              use reducer to handle states for restore process
  -v, --version              print the version number
Report bugs to contact@anastasis.lu.
Home page: https://anastasis.lu/
General help using GNU software: http://www.gnu.org/gethelp/
```

Examples:

Initialise a backup state
```
BFILE=$(mktemp /tmp/anastasis-state-XXX)
anastasis-reducer -b "$BFILE"
```

Initialise a recovery state
```
RFILE=$(mktemp /tmp/anastasis-state-XXX)
anastasis-reducer -r "$RFILE"
```

The state files are json formated and can be inspected this way
```
jq -r -e .recovery_state < $RFILE
```

## Gnunet configuration file manager (either client or server)

anastasis-config, a.k.a. gnunet-config

```
gnunet-config [OPTIONS]
Manipulate GNUnet configuration files
Arguments mandatory for long options are also mandatory for short options.
  -b, --supported-backend=BACKEND
                             test if the current installation supports the
                               specified BACKEND
  -c, --config=FILENAME      use configuration file FILENAME
  -d, --diagnostics          output extra diagnostics
  -F, --full                 write the full configuration file, including
                               default values
  -f, --filename             interpret option value as a filename (with
                               $-expansion)
  -h, --help                 print this help
  -L, --log=LOGLEVEL         configure logging to use LOGLEVEL
  -l, --logfile=FILENAME     configure logging to write logs to FILENAME
  -o, --option=OPTION        name of the option to access
  -r, --rewrite              rewrite the configuration file, even if nothing
                               changed
  -S, --list-sections        print available configuration sections
  -s, --section=SECTION      name of the section to access
  -V, --value=VALUE          value to set
  -v, --version              print the version number
Report bugs to contact@anastasis.lu.
Home page: https://anastasis.lu/
General help using GNU software: http://www.gnu.org/gethelp/
```
