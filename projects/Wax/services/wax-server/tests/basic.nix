{
  sources,
  pkgs,
  ...
}:
{
  name = "wax";

  nodes = {
    machine =
      { ... }:
      {
        imports = [
          sources.modules.ngipkgs
          sources.modules.services.wax-server
          sources.modules.programs.wax-client
          "${sources.inputs.nixpkgs}/nixos/tests/common/x11.nix"
        ];

        environment.systemPackages = with pkgs; [
          firefox
          wax-client
          wax-server
        ];
        environment.variables = {
          POSTGRES_DB = "wax";
          POSTGRES_USER = "wax";
          POSTGRES_HOST = "localhost";
          S3_ACCESS_KEY_ID = "12345";
          S3_SECRET_ACCESS_KEY = "12345678";
          S3_URL = "http://127.0.0.1:9001";
        };

        services.postgresql = {
          enable = true;
          settings = {
            port = 5432;
          };
          ensureDatabases = [ "wax" ];
          ensureUsers = [
            {
              name = "wax";
              ensureDBOwnership = true;
            }
          ];
          authentication = ''
            host  wax wax 127.0.0.1/32 trust
          '';
        };

        services.minio = {
          enable = true;
          accessKey = "12345";
          listenAddress = ":9000";
          consoleAddress = ":9001";
          secretKey = "12345678";
        };
      };
  };

  testScript =
    { nodes, ... }:
    ''
      start_all()
    '';
}
