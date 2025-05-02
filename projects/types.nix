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
{
  subgrantType =
    with types;
    submodule {
      options = lib.genAttrs [ "Commons" "Core" "Entrust" "Review" ] (
        name:
        mkOption {
          type = listOf str;
          default = [ ];
        }
      );
    };
}
