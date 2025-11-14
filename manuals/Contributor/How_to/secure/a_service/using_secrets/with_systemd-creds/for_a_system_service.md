{#Contributor_How_to_secure_a_service_using_secrets_with_systemd-creds_for_a_system_service}
# For a system service

[systemd-creds](https://www.freedesktop.org/software/systemd/man/latest/systemd-creds.html)
encrypts a system secret with:
```bash
systemd-creds encrypt --name privateKey ./privateKey ./privateKey.cred
```

:::{warning}
By default `systemd-creds`
uses `/var/lib/systemd/credential.secret`,
`/etc/machine-id`, and any TPM chip on the encrypting host.
:::

When the secret (here `cfg.privateKeyFile`) is accessed
through a file given as parameter (here `--privateKey`):
```nix
{
  options = {
    privateKey = lib.mkOption {
      type = lib.types.str;
      description = ''
        Private key file.

        It is loaded using `LoadCredentialEncrypted=`
        when its path is prefixed by a credential name and colon,
        otherwise `LoadCredential=` is used.
      '';
    };
  };
  config = {
    systemd.services.${service} = {
      serviceConfig =
        let
          privateKeyCred = builtins.split ":" cfg.privateKey;
        in
        lib.mkMerge [
          {
            ExecStart = lib.escapeShellArgs [
              (lib.getExe cfg.package)
              "--privateKey"
              "\${CREDENTIALS_DIRECTORY}/${
                if lib.length privateKeyCred > 1 then lib.head privateKeyCred else "privateKey"
              }"
            ];
          }
          (
            if lib.length privateKeyCred > 1 then
              { LoadCredentialEncrypted = [ cfg.privateKeyFile ]; }
            else
              { LoadCredential = [ "privateKey:${cfg.privateKeyFile}" ]; }
          )
        ];
    };
  };
}
```

When the secret (here `cfg.privateKeyFile`) needs to be accessed
at a specific location (here `${stateDir}/key`):
```nix
systemd.services.${service} = {
serviceConfig =
  let
    keyCred = builtins.split ":" "${cfg.privateKeyFile}";
  in
  if lib.length keyCred > 1 then
    {
      LoadCredentialEncrypted = [ cfg.privateKeyFile ];
      # Explanation: neither %d nor ${CREDENTIALS_DIRECTORY} work in BindReadOnlyPaths=
      # hence hardcode /run/credentials/${service}.service
      BindReadOnlyPaths = [
        "/run/credentials/${service}.service/${lib.head keyCred}:${stateDir}/key"
      ];
    }
  else
    {
      LoadCredential = [ "radicle:${cfg.privateKeyFile}" ];
      BindReadOnlyPaths = [
        "/run/credentials/${service}.service/radicle:${stateDir}/key"
      ];
    };
};
```

