{
  lib,
  config,
  pkgs,
  ...
}:
let
  cfg = config.eris-server;
  inherit (lib)
    getExe
    getExe'
    mkOption
    types
    ;
  configFormat = pkgs.formats.json { };
  toJSON = lib.generators.toJSON { };
in
{
  _class = "service";

  options = {
    eris-server = {
      package = mkOption {
        description = "Package to source for the ERIS server";
        type = types.package;
      };

      settings = mkOption {
        type = configFormat.type;
        description = ''
          Configuration of `eris-server`.
          For a description of the recognized
          options see {manpage}`eris-go(5)` or
          [eris-go.5.md](https://codeberg.org/eris/eris-go/src/branch/trunk/eris-go.5.md).
        '';
      };
    };
  };

  config = {
    eris-server.settings = {
      command = "server";
    };

    process.argv = [
      (getExe' pkgs.execline "heredoc")
      "0"
      (toJSON cfg.settings)
      (getExe cfg.package)
      "loadconfig"
    ];
  };
}
