{
  lib,
  config,
  ...
}:
let
  cfg = config.programs.xrsh;
in
{
  config = lib.mkIf cfg.enable {
    demo-shell = {
      programs = {
        xrsh = cfg.package;
      };
      env.XRSH_PORT = toString cfg.port;
      # usage-instructions = ''
      #   Run 'xrsh' to start the web server and go to https://localhost:${toString cfg.port}
      # '';
    };
  };
}
