# To test dnsvizor running as a recursive DNS resolver, we setup a
# root DNS server, a TLD DNS server and an authoritative DNS server.
# To let dnsvizor query our root DNS server instead of real root DNS
# servers, we setup a firewall to deceive dnsvizor.

# To test dnsvizor running as a stub DNS resolver, we forward its
# query to another DNS server, which typically should be a recursive
# DNS resolver in production.  For simplicity, we forward dnsvizor
# queries to the authoritative DNS server we setup in the recursive
# DNS resolver test.

# When cfg.openFirewall, we query dnsvizor DNS resolver from another
# machine.  Otherwise, we query from the same machine running the
# resolver.

# IPv6 is preferred/tested when dnsvizor enables both IPv4 and IPv6.

{
  lib,
  sources,
  exampleName,
  resolverKind,
  useNetworkd,
  useNftables,
  ...
}:

assert builtins.elem resolverKind [
  "stub"
  "recursive"
];
assert builtins.isBool useNetworkd;

let
  vlan = 1;
  commonDnsServerModule = {
    services.knot = {
      enable = true;
      settings = {
        server = {
          listen = [ "0.0.0.0@53" ];
        };
        log.syslog.any = "info";
        template.default = {
          semantic-checks = true;
        };
      };
    };
    networking.firewall = {
      allowedUDPPorts = [
        53
      ];
      allowedTCPPorts = [
        53
        853 # openning it can speed up tests with opportunistic-tls-authoritative
      ];
    };
    virtualisation.vlans = [ vlan ];
  };

  commonDnsResolverModule =
    {
      pkgs,
      lib,
      config,
      ...
    }:
    let
      cfg = config.services.dnsvizor;
      mainInterface = "enp1s0";
    in
    {
      imports = [
        sources.modules.ngipkgs
        sources.modules.services.dnsvizor
      ];

      virtualisation.interfaces.${mainInterface} = {
        inherit vlan;
        assignIP = true;
      };

      services.dnsvizor = {
        mainInterface = lib.mkForce mainInterface;
        settings = {
          dns-blocklist-url =
            let
              ipAndFiles = [
                {
                  authority = cfg.settings.ipv4-gateway;
                  path = "/dns-block-4";
                }
              ]
              ++ lib.optional cfg.ipv6Enabled {
                # dnsvizor errors without a port
                authority = "${quoteIpv6 cfg.settings.ipv6-gateway}:80";
                path = "/dns-block-6";
              };
              mkAddress = { authority, path }: "http://${authority}${path}";
            in
            lib.mkForce (map mkAddress ipAndFiles);
        };
      };

      services.caddy = {
        enable = true;
        virtualHosts.dnsBlockLists = {
          hostName = "http://";
          extraConfig =
            let
              dnsBlockList4 = pkgs.writeTextDir "dns-block-4" ''
                block1.url.example.com
                block2.url.example.com
              '';
              dnsBlockList6 = pkgs.writeTextDir "dns-block-6" ''
                block3.url.example.com
                block4.url.example.com
              '';
              dnsBlockListDir = pkgs.symlinkJoin {
                name = "dns-block-lists";
                paths = [
                  dnsBlockList4
                  dnsBlockList6
                ];
              };
            in
            ''
              root ${dnsBlockListDir}
              file_server
            '';
          logFormat = ""; # let systemd also handle access log
        };
        logFormat = "level INFO";
      };
      networking.firewall.trustedInterfaces = [ cfg.unikernelInterface ];
      systemd.services.dnsvizor = {
        wants = [ "caddy.service" ];
        after = [ "caddy.service" ];
      };

      networking.hosts = lib.optionalAttrs (cfg.settings.hostname != null) (
        {
          ${cfg.ipv4Prefix} = [ cfg.settings.hostname ];
        }
        // lib.optionalAttrs cfg.ipv6Enabled {
          ${cfg.ipv6Prefix} = [ cfg.settings.hostname ];
        }
      );

      networking = {
        inherit useNetworkd;
        nftables.enable = useNftables;
      };

      environment.systemPackages = [ pkgs.q ]; # DNS query tool used in testScript
    };

  emulateRootDnsServer =
    {
      lib,
      config,
      nodes,
      pkgs,
      modulesPath,
      ...
    }:
    let
      cfg = config.services.dnsvizor;
      rootDnsServerRealIpv4s = [
        "198.41.0.4"
        "170.247.170.2"
        "192.33.4.12"
        "199.7.91.13"
        "192.203.230.10"
        "192.5.5.241"
        "192.112.36.4"
        "198.97.190.53"
        "192.36.148.17"
        "192.58.128.30"
        "193.0.14.129"
        "199.7.83.42"
        "202.12.27.33"
      ];
      rootDnsServerRealIpv6s = [
        "2001:503:ba3e::2:30"
        "2801:1b8:10::b"
        "2001:500:2::c"
        "2001:500:2d::d"
        "2001:500:a8::e"
        "2001:500:2f::f"
        "2001:500:12::d0d"
        "2001:500:1::53"
        "2001:7fe::53"
        "2001:503:c27::2:30"
        "2001:7fd::1"
        "2001:500:9f::42"
        "2001:dc3::35"
      ];
    in
    (lib.mkMerge [
      (lib.mkIf config.networking.nftables.enable {
        networking.nftables.tables.emulateRootDnsServer = {
          family = "inet";
          content = ''
            chain prerouting {
              type nat hook prerouting priority dstnat
              ip daddr @root_dns_server_real_ipv4s iifname ${quote cfg.unikernelInterface} dnat to ${getIpv4 nodes.rootDnsServer}
              ip6 daddr @root_dns_server_real_ipv6s iifname ${quote cfg.unikernelInterface} dnat to ${getIpv6 nodes.rootDnsServer}
            }
            set root_dns_server_real_ipv4s {
              type ipv4_addr;
              elements = { ${lib.concatStringsSep "," rootDnsServerRealIpv4s} };
            }
            set root_dns_server_real_ipv6s {
              type ipv6_addr;
              elements = { ${lib.concatStringsSep "," rootDnsServerRealIpv6s} };
            }
          '';
        };
      })
      (lib.mkIf (!config.networking.nftables.enable) {
        systemd.services.emulateRootDnsServer =
          let
            helpers = import (modulesPath + "/services/networking/helpers.nix") { inherit config lib; };
            flush = ''
              ${helpers}
              ip46tables -w -t nat -D PREROUTING -j emulate-root-dns-server 2>/dev/null|| true
              ip46tables -w -t nat -F emulate-root-dns-server 2>/dev/null || true
              ip46tables -w -t nat -X emulate-root-dns-server 2>/dev/null || true
            '';
            setup = ''
              ${helpers}
              ip46tables -w -t nat -N emulate-root-dns-server
              ${rules}
              ip46tables -w -t nat -A PREROUTING -j emulate-root-dns-server
            '';
            rules = lib.concatMapStrings mkRule (
              mkCfgs "iptables" (getIpv4 nodes.rootDnsServer) quoteIpv4 rootDnsServerRealIpv4s
              ++ lib.optionals cfg.ipv6Enabled (
                mkCfgs "ip6tables" (getIpv6 nodes.rootDnsServer) quoteIpv6 rootDnsServerRealIpv6s
              )
            );
            mkRule =
              {
                iptablesCommand,
                rootDnsServerRealIp,
                rootDnsServerTestIp,
              }:
              ''
                ${iptablesCommand} -w -t nat -A emulate-root-dns-server \
                  -i ${cfg.unikernelInterface} \
                  -d ${rootDnsServerRealIp} \
                  -j DNAT --to-destination ${rootDnsServerTestIp}
              '';
            mkCfgs =
              iptablesCommand: rootDnsServerTestIp: quoteIp: rootDnsServerRealIps:
              map (rootDnsServerRealIp: {
                inherit iptablesCommand rootDnsServerTestIp rootDnsServerRealIp;
              }) rootDnsServerRealIps;
            quoteIpv4 = x: x;
          in
          {
            description = "Emulate root DNS server";
            wantedBy = [ "network.target" ];
            after = [
              "network-pre.target"
              "systemd-modules-load.service"
            ];
            path = [ pkgs.iptables ];
            unitConfig.ConditionCapability = "CAP_NET_ADMIN";
            serviceConfig = {
              Type = "oneshot";
              RemainAfterExit = true;
            };
            script = flush + setup;
            postStop = flush;
          };
      })
    ]);

  getIpv4 = node: node.networking.primaryIPAddress;
  getIpv6 = node: node.networking.primaryIPv6Address;

  quote = x: ''"${x}"'';
  quoteIpv6 = ipv6: "[${ipv6}]";
in
{
  name = "DNSvizor";

  nodes = {
    rootDnsServer =
      { pkgs, nodes, ... }:
      {
        imports = [ commonDnsServerModule ];

        services.knot.settings.zone.".".file = pkgs.writeText "zone" ''
          @ SOA a.root-servers.net. nstld.verisign-grs.com. 2026010900 1800 900 604800 86400
          @ NS a.root-servers.net
          a.root-servers.net A 198.41.0.4
          a.root-servers.net AAAA 2001:503:ba3e::2:30
          com NS a.tld-servers.com
          a.tld-servers.com A ${getIpv4 nodes.tldDnsServer}
          a.tld-servers.com AAAA ${getIpv6 nodes.tldDnsServer}
        '';
      };

    tldDnsServer =
      { pkgs, nodes, ... }:
      {
        imports = [ commonDnsServerModule ];

        services.knot.settings.zone."com".file = pkgs.writeText "zone" ''
          @ SOA a.tld-servers.com. hostmaster.tld-servers.com. 1501732 900 1800 6048000 3600
          @ NS a.tld-servers
          a.tld-servers A ${getIpv4 nodes.tldDnsServer}
          a.tld-servers AAAA ${getIpv6 nodes.tldDnsServer}
          example NS ns1.example
          ns1.example A ${getIpv4 nodes.authoritativeDnsServer}
          ns1.example AAAA ${getIpv6 nodes.authoritativeDnsServer}
        '';
      };

    authoritativeDnsServer =
      { pkgs, nodes, ... }:
      {
        imports = [ commonDnsServerModule ];

        services.knot.settings.zone."example.com".file = pkgs.writeText "zone" ''
          @ SOA ns1.example.com. hostmaster.example.com. 2019031301 86400 7200 3600000 172800
          @ NS ns1
          ns1 A ${getIpv4 nodes.authoritativeDnsServer}
          ns1 AAAA ${getIpv6 nodes.authoritativeDnsServer}
          www A 192.168.4.1
          www AAAA 2001:db8::1
          block1.cli A 192.168.5.1
          block2.cli A 192.168.5.2
          block1.url A 192.168.6.1
          block2.url A 192.168.6.2
          block3.url A 192.168.6.3
          block4.url A 192.168.6.4
        '';
      };

    dnsResolver =
      {
        lib,
        nodes,
        config,
        ...
      }:
      let
        cfg = config.services.dnsvizor;
      in
      {
        imports = [
          commonDnsResolverModule
          sources.examples.DNSvizor.${exampleName}
        ]
        ++ lib.optional (resolverKind == "recursive") emulateRootDnsServer;

        services.dnsvizor = {
          settings.dns-upstream =
            let
              ip =
                if cfg.ipv6Enabled then
                  quoteIpv6 (getIpv6 nodes.authoritativeDnsServer)
                else
                  getIpv4 nodes.authoritativeDnsServer;
            in
            lib.mkIf (resolverKind == "stub") (lib.mkForce "udp:${ip}");
        };
      };

    dnsClient =
      { pkgs, nodes, ... }:
      let
        inherit (nodes) dnsResolver;
        dnsResolverCfg = dnsResolver.services.dnsvizor;
      in
      {
        environment.systemPackages = [ pkgs.q ]; # DNS query tool used in testScript

        networking.hosts = lib.optionalAttrs (dnsResolverCfg.settings.hostname != null) (
          {
            ${getIpv4 dnsResolver} = [ dnsResolverCfg.settings.hostname ];
          }
          // lib.optionalAttrs dnsResolverCfg.ipv6Enabled {
            ${getIpv6 dnsResolver} = [ dnsResolverCfg.settings.hostname ];
          }
        );

        virtualisation.vlans = [ vlan ];
      };
  };

  testScript =
    { nodes, ... }:
    let
      inherit (nodes) dnsResolver;
      dnsResolverCfg = dnsResolver.services.dnsvizor;
      dnsResolverIpv4ForQuery =
        if dnsResolverCfg.openFirewall then getIpv4 dnsResolver else dnsResolverCfg.ipv4Prefix;
      dnsResolverIpv6ForQuery =
        if dnsResolverCfg.openFirewall then getIpv6 dnsResolver else dnsResolverCfg.ipv6Prefix;
      protocolPorts = [
        {
          protocol = "plain";
          port = 53;
        }
      ]
      ++ lib.optionals (!dnsResolverCfg.settings.no-tls) [
        {
          protocol = "tls";
          port = 853;
        }
        {
          protocol = "https";
          port = dnsResolverCfg.settings.https-port;
        }
      ];
      mkPythonCollection =
        leftMark: rightMark:
        lib.flip lib.pipe [
          (lib.concatStringsSep ", ")
          (x: "${leftMark} ${x} ${rightMark}")
        ];
      # [{name :: string, value :: string}] -> PythonDict
      mkPythonDict = lib.flip lib.pipe [
        (map ({ name, value }: "${name}: ${value}"))
        (mkPythonCollection "{" "}")
      ];
      protocolPortsPython =
        let
          mkPair = { protocol, port }: lib.nameValuePair (quote protocol) (builtins.toString port);
        in
        mkPythonDict (map mkPair protocolPorts);
      dnsResolverIpOrDomains = [
        dnsResolverIpv4ForQuery
      ]
      ++ lib.optional dnsResolverCfg.ipv6Enabled (quoteIpv6 dnsResolverIpv6ForQuery)
      ++ lib.optional (dnsResolverCfg.settings.hostname != null) dnsResolverCfg.settings.hostname;
      # [string] -> PythonList
      mkPythonList = mkPythonCollection "[" "]";
      dnsResolverIpOrDomainsPython = mkPythonList (map quote dnsResolverIpOrDomains);
      dnsQueryAndExpectedAnswers = [
        {
          query = "www.example.com";
          queryType = "A";
          expectedAnswer = "192.168.4.1";
        }
        {
          query = "www.example.com";
          queryType = "AAAA";
          expectedAnswer = "2001:db8::1";
        }
        {
          query = "block1.cli.example.com";
          queryType = "A";
          expectedAnswer = null;
        }
        {
          query = "block2.cli.example.com";
          queryType = "A";
          expectedAnswer = null;
        }
        {
          query = "block1.url.example.com";
          queryType = "A";
          expectedAnswer = null;
        }
        {
          query = "block2.url.example.com";
          queryType = "A";
          expectedAnswer = null;
        }
      ]
      ++ lib.optionals dnsResolverCfg.ipv6Enabled [
        {
          query = "block3.url.example.com";
          queryType = "A";
          expectedAnswer = null;
        }
        {
          query = "block4.url.example.com";
          queryType = "A";
          expectedAnswer = null;
        }
      ]
      ++ lib.optionals (dnsResolverCfg.settings.hostname != null && !dnsResolverCfg.settings.no-hosts) (
        [
          {
            query = dnsResolverCfg.settings.hostname;
            queryType = "A";
            expectedAnswer = dnsResolverCfg.ipv4Prefix;
          }
        ]
        ++ lib.optionals dnsResolverCfg.ipv6Enabled [
          {
            query = dnsResolverCfg.settings.hostname;
            queryType = "AAAA";
            expectedAnswer = dnsResolverCfg.ipv6Prefix;
          }
        ]
      );
      # [string] -> PythonTuple
      mkPythonTuple = mkPythonCollection "(" ")";
      dnsQueryAndExpectedAnswersPython =
        let
          quoteIfNonNull = x: if x == null then "None" else quote x;
          mkList =
            {
              query,
              queryType,
              expectedAnswer,
            }:
            [
              query
              queryType
              expectedAnswer
            ];
          mkTuple = attrset: mkPythonTuple (map quoteIfNonNull (mkList attrset));
        in
        mkPythonList (map mkTuple dnsQueryAndExpectedAnswers);
      webInterfaceDomainOrIp =
        if dnsResolverCfg.settings.hostname == null then
          if dnsResolverCfg.ipv6Enabled then quoteIpv6 dnsResolverIpv6ForQuery else dnsResolverIpv4ForQuery
        else
          dnsResolverCfg.settings.hostname;
    in
    ''
      if "${resolverKind}" == "stub":
          dns_servers = [ authoritativeDnsServer ];
      else:
          dns_servers = [ rootDnsServer, tldDnsServer, authoritativeDnsServer ]
      dns_resolver = dnsResolver
      dns_client = ${if dnsResolverCfg.openFirewall then "dnsClient" else "dnsResolver"}

      dns_resolver.start()
      for dns_server in dns_servers:
          dns_server.start()
      dns_client.start()

      for dns_server in dns_servers:
          dns_server.wait_for_unit("multi-user.target")
      dns_resolver.wait_for_unit("multi-user.target")
      dns_client.wait_for_unit("multi-user.target")
      for dns_server in dns_servers:
          dns_server.wait_for_unit("knot.service")
          dns_server.wait_until_succeeds('journalctl -u knot -g "zone file loaded"')
      dns_resolver.wait_for_unit("dnsvizor.service")
      dns_resolver.wait_until_succeeds('journalctl -u dnsvizor -g "${
        if resolverKind == "stub" then "forwarding to" else "listening on"
      }"')
      # we assume the DNS block list is loaded after it is accessed on the web server
      dns_resolver.wait_for_unit("caddy.service")
      dns_resolver.wait_until_succeeds("journalctl -u caddy -g http.log.access")

      dns_client.log("I am the DNS client")

      with subtest("Web interface can be accessed"):
          web_interface_url = "https://${webInterfaceDomainOrIp}"
          if ${if dnsResolverCfg.settings.hostname == null then "True" else "False"}:
              command = f"curl --insecure {web_interface_url}"
          else:
              self_signed_cert = "/tmp/self-signed-cert.pem"
              dns_client.fail(f"curl --write-out %{{certs}} {web_interface_url} >{self_signed_cert}")
              dns_client.succeed(f'grep "BEGIN CERTIFICATE" {self_signed_cert}')
              command = f"curl --cacert {self_signed_cert} {web_interface_url}"
          html = dns_client.succeed(command)
          assert "DNSvizor" in html, "fail to check web interface"

      def test_dns(dns_resolver_url, query, query_type, expected_answer):
          query_command = " ".join([
              "q",
              "--format=json",
              # self_signed_cert changes each time dnsvizor restarts
              # to not make test flaky, we ignore TLS error instead of using self_signed_cert
              "--tls-insecure-skip-verify",
              f"@{dns_resolver_url}",
              query_type,
              query,
          ])
          import json
          output = json.loads(dns_client.wait_until_succeeds(query_command))
          actual_answer = output[0]['replies'][0]["answer"]
          def check_answer(expected_answer, actual_answer):
              if expected_answer is None:
                  return expected_answer == actual_answer
              else:
                  if actual_answer is None:
                      return False
                  for answer in actual_answer:
                      if answer[query_type.lower()] == expected_answer:
                          return True
                  return False
          assert check_answer(expected_answer, actual_answer), f"expect {expected_answer}, got {actual_answer}"
      for protocol, port in (${protocolPortsPython}).items():
          for dns_resolver_ip_or_domain in ${dnsResolverIpOrDomainsPython}:
              dns_resolver_url = f"{protocol}://{dns_resolver_ip_or_domain}:{port}"
              with subtest(f"DNS query results from {dns_resolver_url} are correct"):
                  for query, query_type, expected_answer in ${dnsQueryAndExpectedAnswersPython}:
                      test_dns(dns_resolver_url, query, query_type, expected_answer)

      with subtest("Systemd hardening works, exposure level is low"):
          output = dns_resolver.succeed("systemd-analyze security dnsvizor.service | grep -v ✓")
          dns_resolver.log(output)
          assert " OK " in output, "overall exposure level too high"
    '';
}
