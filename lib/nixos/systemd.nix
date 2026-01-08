{ ... }:
lib: previousLib: {
  types = previousLib.types // {
    credential = lib.types.either lib.types.path (
      lib.types.submodule {
        options = {
          name = lib.mkOption {
            type = lib.types.string;
            description = "credential name";
          };
          path = lib.mkOption {
            type = lib.types.path;
            description = "credential path";
          };
          encrypted = lib.mkEnableOption "the credential is encrypted with `systemd-creds`";
        };
      }
    );
  };
  systemd = {
    serviceConfig = {
      # loadCredential :: string -> credential -> serviceConfig
      loadCredential =
        defaultName: cred:
        if lib.types.path.check cred then
          {
            LoadCredential = [ "${cred.name or defaultName}:${cred}" ];
          }
        else if cred.encrypted then
          {
            LoadCredentialEncrypted = [ "${cred.name or defaultName}:${cred.path}" ];
          }
        else
          {
            LoadCredential = [ "${cred.name or defaultName}:${cred.path}" ];
          };
    };
  };
}
