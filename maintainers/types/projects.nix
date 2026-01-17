{
  lib,
  ...
}:

let
  inherit (lib)
    types
    mkOption
    ;

  ngiTypes = import ./. { inherit lib; };

  inherit (ngiTypes)
    project
    ;
in

{
  options.projects = mkOption {
    type = with types; attrsOf project;
    description = "NGI-funded software application";
  };
}
