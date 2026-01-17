{
  lib,
  ...
}:

let
  inherit (lib)
    types
    mkOption
    ;
in

types.attrTag {
  broken = mkOption {
    description = "Indicates that a component is broken and needs fixing";
    type = types.submodule {
      options.reason = mkOption {
        description = "Explanation of why a component is broken, with links to logs, issues, or potential fixes";
        type = types.str;
      };
    };
  };
}
