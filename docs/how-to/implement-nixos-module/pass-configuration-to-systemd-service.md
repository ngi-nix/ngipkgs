# How to pass configuration to a program launched as a systemd service

## Using configuration file

```nix
  let
    configFile = writeText "myapp.conf" ''
      <CONFIGURATION>
    '';
  in
  {
    systemd.services.myapp = {
      wantedBy = [ "multi-user.target" ];
      serviceConfig = {
        ExecStart = "${lib.getExe cfg.package} -c ${configFile}";
        # Note: use dynamic user if possible instead
        User = cfg.user;
        Group = cfg.group;
      };
    };
  }
```

## Using configuration file and environment variables

```nix
 let
    configFile = writeText "myapp.conf" ''
      <CONFIGURATION>
    '';
  in
  {
    systemd.services.myapp = {
      wantedBy = [ "multi-user.target" ];
      serviceConfig = {
        ExecStart = "${lib.getExe cfg.package}";
        Environment = [
          "CONFIG_FILE=${configFile}"
          "LOG_LEVEL=${cfg.logLevel}"
          # ...
        ];
        # Note: use dynamic user if possible instead
        User = cfg.user;
        Group = cfg.group;
      };
    };
  }
```

## Notes

* Always validate the configuration file at build time (or at run time at minimum)
* Use `systemctl edit --runtime <service>` to debug service configuration (automatically reloads after editing)

