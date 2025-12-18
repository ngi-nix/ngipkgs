# How to pass credentials to a systemd service

```nix
    systemd.services.myservice = {
      serviceConfig = {
        # Note: use dynamic user if possible instead
        User = cfg.user;
        Group = cfg.group;
        LoadCredential = lib.optional (cfg.database.passwordFile != null) [
          "db_password:${cfg.database.passwordFile}"  # passwordFile provided by secrets manager
        ];
        Environment = [
          "PGHOST=${cfg.database.host}"
          "PGUSER=${cfg.database.user}"
          "PGDATABASE=${cfg.database.dbname}"
          "PGPASSFILE=%d/db_password"
        ];
      };
    };
```

## Notes

* Credentials must be provided as strings stored in a file decrypted by a secrets manager such as sops or agenix
* The `%d` variable in `PGPASSFILE=%d/db_password` refers to the credentials directory managed by systemd

* systemd also provides built-in secrets management (must be decrypted by TPM chip)

```nix
  systemd.services.sshd.serviceConfig.LoadCredentialEncrypted = [
    "host.key:${ssh/host.key.cred}"
  ];
```

## Links

* [systemd credentials](https://systemd.io/CREDENTIALS/)
