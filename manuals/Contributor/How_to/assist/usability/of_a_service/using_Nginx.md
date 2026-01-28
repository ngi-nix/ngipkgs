{#Contributor_How_to_assist_usability_of_a_service_using_Nginx}
# How to assist usability of a service using Nginx?

A service can provide a convenient opt-in option
to integrate a virtual-host in `services.nginx`, acting as a reverse-proxy:

```nix
{ pkgs, config, lib, modulesPath, ...}:
{
  options.services.${service} = {
    enable = lib.mkEnableOption "an Nginx reverse-proxy to ${service}";
    virtualHost = lib.mkOption {
      description = ''
        With this option, you can customize the nginx virtual host which already has sensible defaults for `${service}`.
        By default, the {option}`serverName` is
        `${service}.''${config.networking.domain}`,
        TLS is active, and certificates are acquired via ACME.
      '';
      default = {};
      example = lib.literalExpression ''
        {
          enableACME = false;
          useACMEHost = config.networking.domain;
        }
      '';
      type =
        lib.types.submodule (
          lib.recursiveUpdate
            (import (modulesPath + "/services/web-servers/nginx/vhost-options.nix") {
              inherit config lib;
            })
            {
              options.serverName = {
                default = "${service}.${config.networking.domain}";
                defaultText = "${service}.\${config.networking.domain}";
              };
            }
        );
    };
  };
  config = lib.mkIf cfg.enable (
    lib.mkMerge [
      (lib.mkIf cfg.nginx.enable {
        services.nginx = {
          enable = lib.mkDefault true;
          virtualHosts.${cfg.nginx.serverName} = lib.mkMerge [
            cfg.nginx.virtualHost
            {
              forceSSL = lib.mkDefault true;
              enableACME = lib.mkDefault true;
              locations."/" = {
                proxyPass = "http://unix:/run/${service}/socket";
                recommendedProxySettings = true;
                proxyWebsockets = true;
              };
            }
          ];
        };
        systemd.services.nginx.serviceConfig.SupplementaryGroups = [
          config.users.groups.${service}.name
        ];
      })
    ]
  );
}
```
