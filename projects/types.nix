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
      options =
        lib.genAttrs
          [
            "Commons"
            "Core"
            "Entrust"
            "Review"
          ]
          (
            name:
            mkOption {
              type = listOf str;
              default = [ ];
            }
          );
    };

  link =
    with types;
    submodule (
      { name, ... }:
      {
        options = {
          text = mkOption {
            description = "link text";
            type = str;
            default = name;
          };
          description = mkOption {
            description = "long-form description of the linked resource";
            type = nullOr str;
            default = null;
          };
          # TODO: add syntax checking
          url = mkOption {
            type = str;
          };
        };
      }
    );

  binary =
    with types;
    submodule (
      { name, ... }:
      {
        options = {
          name = mkOption {
            type = str;
            default = name;
          };
          data = mkOption {
            type = nullOr (either path package);
            default = null;
          };
        };
      }
    );

  # TODO: plugins are actually component *extensions* that are of component-specific type,
  #       and which compose in application-specific ways defined in the application module.
  #       this also means that there's no fundamental difference between programs and services,
  #       and even languages: libraries are just extensions of compilers.
  # TODO: implement this, now that we're using the module system
  plugin = with types; anything;
}
