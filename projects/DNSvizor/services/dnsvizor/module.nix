{
  config,
  lib,
  pkgs,
  utils,
  ...
}:

# TODO(linj) implement and test DHCP-related things
#   - run dnsvizor as a DHCP server
#   - update DNS record in the authoritative DNS server when DHCP ip changes
#   - update config for tlstunnel mirageos unikernel when DHCP ip changes
# TODO(linj) implement and test DNSSEC
# TODO(linj) implement and test --ipv6-only: currently we assume ipv4 is always there and have implemented/tested --ipv4-only and dual stack configs
#   - dnsvizor always has a default value for --ipv4 (but not ipv4-gateway?), seems conflict with --ipv6-only?

let
  cfg = config.services.dnsvizor;
  moreDoc = ''
    See [upstream online documentation](https://robur-coop.github.io/dnsvizor-handbook/dnsvizor_options.html) for more information.
    Setting {option}`services.dnsvizor.settings.help` shows the help message locally at runtime.
  '';
  secretWarning = ''
    ::: {.warning}
    This secret will be copied into the nix store in clear text.
    :::
  '';
  allowedUDPPorts = [ 53 ];
  allowedTCPPorts = [
    53
  ]
  ++ lib.optionals (!cfg.settings.no-tls) [
    cfg.settings.https-port
    853
  ];
  onlyOneIsNull = x: y: x == null && y != null || x != null && y == null;
in
{
  options.services.dnsvizor = {
    enable = lib.mkEnableOption "dnsvizor";

    package = lib.mkPackageOption pkgs "dnsvizor (hvt target)" {
      default = [
        "dnsvizor"
        "hvt"
      ];
      extraDescription = "We assume dnsvizor.hvt exists at the root dir of the package.";
    };

    memory = lib.mkOption {
      type = lib.types.ints.positive;
      default = 512;
      description = "Memory limit of the unikernel in MB.";
    };

    settings = lib.mkOption {
      type = lib.types.submodule {
        freeformType = lib.types.attrsOf (
          lib.types.nullOr (
            lib.types.oneOf [
              lib.types.bool
              lib.types.str
              (lib.types.listOf lib.types.str)
            ]
          )
        );
        options = {
          ipv4 = lib.mkOption {
            type = lib.types.str;
            default = "10.0.0.2/24";
            description = ''
              IPv4 network address and prefix length for the unikernel.  ${moreDoc}
            '';
          };
          ipv4-gateway = lib.mkOption {
            type = lib.types.str;
            default = "10.0.0.1";
            description = "IPv4 gateway of the unikernel.  ${moreDoc}";
          };
          ipv4-only = lib.mkOption {
            type = lib.types.nullOr (
              lib.types.enum [
                "true"
                "false"
              ]
            );
            default = null;
            example = "true";
            description = "Only use IPv4 for the unikernel.  ${moreDoc}";
          };
          ipv6 = lib.mkOption {
            type = lib.types.nullOr lib.types.str;
            default = null;
            description = ''
              IPv6 network address and prefix length for the unikernel.  ${moreDoc}
            '';
          };
          ipv6-gateway = lib.mkOption {
            type = lib.types.nullOr lib.types.str;
            default = null;
            description = "IPv6 gateway of the unikernel.  ${moreDoc}";
          };
          ipv6-only = lib.mkOption {
            type = lib.types.nullOr (
              lib.types.enum [
                "true"
                "false"
              ]
            );
            default = null;
            example = "true";
            description = "Only use IPv6 for the unikernel.  ${moreDoc}";
          };
          # TODO(linj) is this a secret, like the `pasword` option?
          ca-seed = lib.mkOption {
            type = lib.types.nullOr lib.types.str;
            default = null;
            example = "Te9ffyY3Clcaz/4P7eFLyZQfLWIz/fSSK4NDb8THMDc=";
            description = ''
              The seed (base64 encoded) used to generate the private key for the certificate.
              ${moreDoc}
            '';
          };
          # TODO talk to upstream for more secure ways to provide secrets at runtime
          password = lib.mkOption {
            type = lib.types.nullOr lib.types.str;
            default = null;
            example = "passwordWithOne\\ space";
            description = ''
              Password used for authentication.  ${moreDoc}

              ::: {.tip}
              The space character needs to be escaped with `\\`.
              :::

              ${secretWarning}
            '';
          };
          dns-upstream = lib.mkOption {
            type = lib.types.nullOr lib.types.str;
            default = null;
            example = "tls:1.1.1.1";
            description = ''
              Upstream DNS resolver.
              By default, it runs as a recursive DNS resolver.
              If this is specified, it runs as a stub DNS resolver instead.
              ${moreDoc}
            '';
          };
          hostname = lib.mkOption {
            type = lib.types.nullOr lib.types.str;
            default = null;
            example = "dnsvizor.mydomain.com";
            description = ''
              The hostname (SNI for the certificate, entry in DNS) of the unikernel.
              ${moreDoc}
            '';
          };
          dns-block = lib.mkOption {
            type = lib.types.listOf lib.types.str;
            default = [ ];
            example = [
              "block1.cli.example.com"
              "block2.cli.example.com"
            ];
            description = "Domains to block.  ${moreDoc}";
          };
          dns-blocklist-url = lib.mkOption {
            type = lib.types.listOf lib.types.str;
            default = [ ];
            example = [
              "http://10.0.0.1/block-list-4"
              "http://[fdc9:281f:4d7:9ee9::1]:80/block-list-6"
              "https://example.com/non-existent-block-list"
            ];
            description = "Web addresses to fetch DNS block lists from.  ${moreDoc}";
          };
          qname-minimisation = lib.mkOption {
            type = lib.types.bool;
            default = false;
            example = true;
            description = "Use qname minimisation (RFC 9156).  ${moreDoc}";
          };
          opportunistic-tls-authoritative = lib.mkOption {
            type = lib.types.bool;
            default = false;
            example = true;
            description = ''
               Use opportunistic TLS from recursive resolver to authoriative (RFC 9539).
              ${moreDoc}
            '';
          };
          # TODO report to upstream that "Query log" web page is always empty
          https-port = lib.mkOption {
            type = lib.types.port;
            default = 443;
            description = "The HTTPS port.  ${moreDoc}";
          };
          no-tls = lib.mkOption {
            type = lib.types.bool;
            default = cfg.settings.ca-seed == null;
            defaultText = lib.literalExpression ''
              config.services.dnsvizor.settings.ca-seed == null
            '';
            example = true;
            description = ''
              Disable TLS: web interface and DNS-over-TLS/DNS-over-HTTPS.
              ${moreDoc}
            '';
          };
          no-hosts = lib.mkOption {
            type = lib.types.bool;
            default = false;
            example = true;
            description = ''
              Don't read the synthesized /etc/hosts which contains only
              {option}`services.dnsvizor.hostname`.
              ${moreDoc}
            '';
          };
          help = lib.mkOption {
            type = lib.types.bool;
            default = false;
            example = true;
            description = "Show help instead of running the unikernel.  ${moreDoc}";
          };
        };
      };
      default = { };
      description = "Configuration for the unikernel.  ${moreDoc}";
    };

    mainInterface = lib.mkOption {
      type = lib.types.str;
      example = "enp4s0";
      description = "The main network interface of the host.";
    };

    openFirewall = lib.mkEnableOption "opening ports in the firewall for dnsvizor";

    unikernelInterface = lib.mkOption {
      type = lib.types.str;
      default = "tap-unikernel";
      internal = true;
      visible = false;
      description = "The TAP interface used by the unikernel.";
    };
    ipv4Prefix = lib.mkOption {
      type = lib.types.str;
      default = lib.elemAt (lib.splitString "/" cfg.settings.ipv4) 0;
      defaultText = lib.literalExpression ''
        lib.elemAt (lib.splitString "/" config.services.dnsvizor.settings.ipv4) 0
      '';
      example = "10.0.0.2";
      internal = true;
      visible = false;
      readOnly = true;
      description = "The prefix of {option}`services.dnsvizor.settings.ipv4`.";
    };
    ipv4Suffix = lib.mkOption {
      type = lib.types.str;
      default = lib.elemAt (lib.splitString "/" cfg.settings.ipv4) 1;
      defaultText = lib.literalExpression ''
        lib.elemAt (lib.splitString "/" config.services.dnsvizor.settings.ipv4) 1
      '';
      example = "24";
      internal = true;
      visible = false;
      readOnly = true;
      description = "The suffix of {option}`services.dnsvizor.settings.ipv4`.";
    };
    ipv6Prefix = lib.mkOption {
      type = lib.types.str;
      default = lib.elemAt (lib.splitString "/" cfg.settings.ipv6) 0;
      defaultText = lib.literalExpression ''
        lib.elemAt (lib.splitString "/" config.services.dnsvizor.settings.ipv6) 0
      '';
      internal = true;
      visible = false;
      readOnly = true;
      description = "The prefix of {option}`services.dnsvizor.settings.ipv6`.";
    };
    ipv6Suffix = lib.mkOption {
      type = lib.types.str;
      default = lib.elemAt (lib.splitString "/" cfg.settings.ipv6) 1;
      defaultText = lib.literalExpression ''
        lib.elemAt (lib.splitString "/" config.services.dnsvizor.settings.ipv6) 1
      '';
      internal = true;
      visible = false;
      readOnly = true;
      description = "The suffix of {option}`services.dnsvizor.settings.ipv6`.";
    };
    ipv6Enabled = lib.mkOption {
      type = lib.types.bool;
      default = cfg.settings.ipv6 != null && cfg.settings.ipv4-only != "true";
      defaultText = lib.literalExpression ''
        config.services.dnsvizor.settings.ipv6 != null && config.services.dnsvizor.settings.ipv4-only != "true";
      '';
      internal = true;
      visible = false;
      readOnly = true;
      description = "Whether IPv6 is enabled.";
    };
  };

  config = lib.mkIf cfg.enable {
    systemd.services.dnsvizor = {
      description = "dnsvizor recursive/stub DNS resolver and DHCP server";
      documentation = [ "https://robur-coop.github.io/dnsvizor-handbook/" ];
      wantedBy = [ "multi-user.target" ];
      bindsTo = [ "sys-subsystem-net-devices-${utils.escapeSystemdPath cfg.unikernelInterface}.device" ];
      after = [ "sys-subsystem-net-devices-${utils.escapeSystemdPath cfg.unikernelInterface}.device" ];
      serviceConfig = {
        ExecStart = ''
          ${lib.getExe' pkgs.solo5 "solo5-hvt"} \
            --mem=${builtins.toString cfg.memory} \
            --net:service=${cfg.unikernelInterface} \
            -- \
            ${cfg.package}/dnsvizor.hvt \
            ${utils.escapeSystemdExecArgs (lib.cli.toCommandLineGNU { } cfg.settings)}
        '';

        # dnsvizor sometimes crashes with DNS-over-HTTPS queries:
        #   Fatal error: exception Invalid_argument("Malformed input")
        # TODO report this crash to upstream
        Restart = "on-failure";

        # hardening
        CapabilityBoundingSet = [ "" ];
        DeviceAllow = [
          "/dev/kvm rw"
          "/dev/net/tun rw"
        ];
        DevicePolicy = "closed";
        DynamicUser = true;
        MemoryDenyWriteExecute = true;
        PrivateUsers = true;
        ProcSubset = "pid";
        ProtectClock = true;
        ProtectControlGroups = true;
        ProtectHome = true;
        ProtectHostname = true;
        ProtectKernelLogs = true;
        ProtectKernelModules = true;
        ProtectKernelTunables = true;
        ProtectProc = "invisible";
        RestrictAddressFamilies = [ "AF_NETLINK" ];
        RestrictNamespaces = true;
        RestrictRealtime = true;
        SystemCallArchitectures = [ "native" ];
        SystemCallFilter = [
          "@system-service"
          "~@privileged"
          "~@resources"
        ];
        SystemCallErrorNumber = "EPERM";
        UMask = "0077";
      };
    };

    networking.useNetworkd = true;
    systemd.network = {
      enable = true;
      netdevs."10-${cfg.unikernelInterface}" = {
        netdevConfig = {
          Name = cfg.unikernelInterface;
          Kind = "tap";
          Description = "Interface connecting the host and the unikernel";
        };
      };
      networks."10-${cfg.unikernelInterface}" = {
        address = [
          "${cfg.settings.ipv4-gateway}/${cfg.ipv4Suffix}"
        ]
        ++ lib.optional cfg.ipv6Enabled "${cfg.settings.ipv6-gateway}/${cfg.ipv6Suffix}";
        matchConfig = {
          Name = cfg.unikernelInterface;
          Kind = "tun";
        };
        networkConfig = {
          IPv4Forwarding = true;
          IPv6Forwarding = lib.mkIf cfg.ipv6Enabled true;
        };
      };
    };
    # to be less invasive, use sysctl instead of networking.* to set forwarding for mainInterface
    boot.kernel.sysctl = {
      "net.ipv4.conf.${cfg.mainInterface}.forwarding" = 1;
    }
    // lib.optionalAttrs cfg.ipv6Enabled {
      "net.ipv6.conf.all.forwarding" = 1; # FIXME setup forwarding firewall
      "net.ipv6.conf.${cfg.mainInterface}.forwarding" = 1;
    };
    # disadvantages of using systemd-networkd to set masquerade
    #   1. changes some unnecessary config (see systemd#34014)
    #   2. results in a larger nft config
    # so we manually write nft config for masquerade
    networking.nftables = {
      enable = true;
      tables.allowUnikernelAccessOutsideWolrd = {
        family = "inet";
        content = ''
          chain postrouting {
            type nat hook postrouting priority srcnat
            ip saddr ${cfg.ipv4Prefix} iifname ${cfg.unikernelInterface} oifname ${cfg.mainInterface} masquerade
            ${lib.optionalString cfg.ipv6Enabled "ip6 saddr ${cfg.ipv6Prefix} iifname ${cfg.unikernelInterface} oifname ${cfg.mainInterface} masquerade"}
          }
        '';
      };
    };

    networking.firewall = lib.optionalAttrs cfg.openFirewall {
      inherit allowedUDPPorts allowedTCPPorts;
    };
    # FIXME use networking.nat.forwardPorts?
    networking.nftables.tables.exposeDnsvizor = lib.mkIf cfg.openFirewall {
      family = "inet";
      content = ''
        set udp_ports {
          type inet_service;
          elements = { ${lib.concatStringsSep "," (map builtins.toString allowedUDPPorts)} };
        }
        set tcp_ports {
          type inet_service;
          elements = { ${lib.concatStringsSep "," (map builtins.toString allowedTCPPorts)} };
        }
        chain prerouting {
          type nat hook prerouting priority dstnat
          iifname ${cfg.mainInterface} udp dport @udp_ports dnat ip to ${cfg.ipv4Prefix}
          iifname ${cfg.mainInterface} tcp dport @tcp_ports dnat ip to ${cfg.ipv4Prefix}
          ${lib.concatStringsSep "\n" (
            lib.optionals cfg.ipv6Enabled [
              "iifname ${cfg.mainInterface} udp dport @udp_ports dnat ip6 to ${cfg.ipv6Prefix}"
              "iifname ${cfg.mainInterface} tcp dport @tcp_ports dnat ip6 to ${cfg.ipv6Prefix}"
            ]
          )}
        }
      '';
    };

    assertions = [
      {
        assertion = !cfg.settings.no-tls -> cfg.settings.ca-seed != null;
        message = "Set services.dnsvizor.settings.ca-seed if services.dnsvizor.settings.no-tls is not set.";
      }
      {
        assertion = !(onlyOneIsNull cfg.settings.ipv6 cfg.settings.ipv6-gateway);
        message = "services.dnsvizor.settings.{ipv6,ipv6-gateway} must be set together.";
      }
      {
        assertion = cfg.settings.ipv6-only != "true";
        message = "services.dnsvizor.settings.ipv6-only has not been implemented.";
      }
    ];

    # TODO remove this after the dnsvizor package is merged into ngipkgs
    services.dnsvizor.package = pkgs.fetchurl {
      pname = "dnsvizor";
      version = "0-unstable-2025-12-30";

      url = "https://builds.robur.coop/job/dnsvizor/build/a763da51-d9d5-46b7-bdb6-da0c1e765ac4/f/bin/dnsvizor.hvt";
      hash = "sha256-PQRZcBMvcxK214QWrCVjAUu0nPsXC8DPjx0TvbrnzB0=";
      recursiveHash = true;

      downloadToTemp = true;
      postFetch = ''
        mkdir -p $out
        mv -v $downloadedFile $out/dnsvizor.hvt
      '';
    };
  };
}
