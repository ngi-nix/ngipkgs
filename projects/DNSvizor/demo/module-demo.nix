{
  lib,
  config,
  pkgs,
  ...
}:

let
  cfg = config.services.dnsvizor;
  quoteIpv6 = ipv6: "[${ipv6}]";
in
{
  config = lib.mkIf cfg.enable {
    services.dnsvizor = {
      mainInterface = lib.mkForce "eth0"; # mkForce because already set in the example module
      openFirewall = true;
    };

    networking.hosts = lib.optionalAttrs (cfg.settings.hostname != null) (
      {
        ${cfg.ipv4Prefix} = [ cfg.settings.hostname ];
      }
      // lib.optionalAttrs cfg.ipv6Enabled {
        ${cfg.ipv6Prefix} = [ cfg.settings.hostname ];
      }
    );

    environment.systemPackages = [
      pkgs.q # DNS query tool
    ];

    virtualisation.forwardPorts = lib.optionals (!cfg.settings.no-tls) ([
      {
        from = "host";
        host.port = 4443; # non-privileged port
        guest.port = cfg.settings.https-port;
        proto = "tcp";
      }
    ]);

    services.caddy = {
      enable = true;
      virtualHosts.dnsBlockLists = {
        hostName = "http://";
        extraConfig =
          let
            dnsBlockList4 = pkgs.writeTextDir "block-list-4" ''
              block1.url.example.com
              block2.url.example.com
            '';
            dnsBlockList6 = pkgs.writeTextDir "block-list-6" ''
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
    systemd.services.dnsvizor = {
      wants = [ "caddy.service" ];
      after = [ "caddy.service" ];
    };
  };
}
