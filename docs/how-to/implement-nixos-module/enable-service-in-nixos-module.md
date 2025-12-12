# How to enable a service in NixOS module

The `services.<service>.enable` option must always enable a working instance of the
service in at least a minimal usable configuration. If other services are required
for the service to work properly, they must be automatically enabled as well.

## Optional services

Optional services must be configurable using additional options. For example, an
optional Nginx reverse proxy can be enabled using:

```nix
options = {
  services.myservice = {
    enable = mkEnableOption "MyService";

    nginx.enable = mkEnableOption "Nginx reverse proxy for MyService";

    domain = mkOption {
      type = types.str;
      default = "localhost";
      description = "Domain name for the service";
    };
  };
};

config = mkIf cfg.enable {
  services.nginx = mkIf cfg.nginx.enable {
    enable = true;
    virtualHosts."${cfg.domain}" = {
      # Nginx configuration for the service
    };
  };
};
```

