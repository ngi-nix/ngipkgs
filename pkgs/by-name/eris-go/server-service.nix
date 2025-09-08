{
  lib,
  config,
  options,
  ...
}:
let
  inherit (lib)
    getExe
    getExe'
    mkMerge
    mkOption
    optional
    types
    ;

  cfg = config.eris-server;

  inherit (cfg.package.passthru) pkgs;

  toJSON = lib.generators.toJSON { };

  synitAvailable = builtins.hasAttr "synit" options;

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
        type = pkgs.jsonFormat.type;
        description = ''
          Configuration of `eris-server`.
          For a description of the recognized
          options see {manpage}`eris-go(5)` or
          [eris-go.5.md](https://codeberg.org/eris/eris-go/src/branch/trunk/eris-go.5.md).
        '';
      };
    };
  };

  config = mkMerge (
    [
      {
        eris-server.settings.command = "server";
        process.argv = [
          "${pkgs.execline}/bin/heredoc"
          "-d"
          "0"
          (toJSON cfg.settings)
          (getExe cfg.package)
          "loadconfig"
        ];
      }
    ]
    ++ optional synitAvailable {
      eris-server.settings.ready-fd = 1;
      synit.daemon.readyOnNotify = 1;
    }
  );
}
