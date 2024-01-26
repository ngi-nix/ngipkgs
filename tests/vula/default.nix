{
  modules,
  pkgs,
  ...
}: {
  name = "vula";

  nodes = {
    server = {config, ...}: {
      imports = [
        modules.default
        modules.vula
      ];
      services.vula.enable = true;
    };
  };

  testScript = {nodes, ...}: ''
    start_all()
  '';

  # NOTE: Below configuration is for "interactive" (=developing/debugging) only.
  interactive.nodes = let
    # Use kmscon <https://www.freedesktop.org/wiki/Software/kmscon/>
    # to provide a slightly nicer console, and while we're at it,
    # also use a nice font.
    # With kmscon, we can for example zoom in/out using [Ctrl] + [+]
    # and [Ctrl] + [-]
    niceConsoleAndAutologin.services.kmscon = {
      enable = true;
      autologinUser = "root";
      fonts = [
        {
          name = "Fira Code";
          package = pkgs.fira-code;
        }
      ];
    };
  in {
    server = niceConsoleAndAutologin;
  };
}
