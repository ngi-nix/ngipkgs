{
  lib,
  config,
  pkgs,
  ...
}:
let
  inherit (lib) mkOption types;

  types' = import ../../projects/types.nix { inherit lib; };
in
{
  imports = [ ./code-snippet.nix ];

  options = {
    inherit (types'.demo.getSubOptions { })
      tests
      problem
      ;
    module = mkOption {
      type = types.path;
    };
    type = mkOption {
      type = types.str;
    };
  };

  # TODO: highlight strings instead of files?
  config.filepath = pkgs.writeText "default.nix" config.snippet-text;
  config.snippet-text = ''
    # default.nix
    {
      ngipkgs ? import (fetchTarball "https://github.com/ngi-nix/ngipkgs/tarball/main") { },
    }:
    ngipkgs.demo-${config.type} (
      ${toString (lib.intersperse "\n " (lib.splitString "\n" (builtins.readFile config.module)))}
    )
  '';
}
