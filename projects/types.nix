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
  subgrant =
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
