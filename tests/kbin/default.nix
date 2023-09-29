{
  configurations,
  modules,
}: {
  name = "kbin";

  nodes = {
    server = {config, ...}: {
      imports = [
        modules.default
        modules.kbin
      ];

      services.kbin = {
        enable = true;
      };

      services = {
        postgresql = {
          enable = true;
          authentication = "local all all trust";
          ensureUsers = [
            {
              name = "kbin";
              ensurePermissions."DATABASE \"kbin\"" = "ALL PRIVILEGES";
            }
          ];
          ensureDatabases = ["kbin"];
          enableTCPIP = true;
        };
      };
      
    };
  };

  testScript = {nodes, ...}: ''
    start_all()

    with subtest("rosenpass"):
        server.wait_for_unit("kbin.service")
  '';

  # NOTE: Below configuration is for "interactive" (=developing/debugging) only.
  interactive.nodes = let
    # Use kmscon <https://www.freedesktop.org/wiki/Software/kmscon/>
    # to provide a slightly nicer console, and while we're at it,
    # also use a nice font.
    # With kmscon, we can for example zoom in/out using [Ctrl] + [+]
    # and [Ctrl] + [-]
    niceConsoleAndAutologin = { pkgs, ...}: {
      services.kmscon = {
        enable = true;
        autologinUser = "root";
        fonts = [{
          name = "Fira Code";
          package = pkgs.fira-code;
        }];
      };
    };
  in {
    server = niceConsoleAndAutologin;
  };
}
