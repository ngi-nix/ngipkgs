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
              description = "subgrants under the ${name} fund";
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

  nonEmtpyAttrs =
    elemType:
    with types;
    (
      (attrsOf elemType)
      // {
        name = "nonEmtpyAttrs";
        description = "non-empty attribute set";
        check = x: lib.isAttrs x && x != { };
      }
    );

  example =
    with types;
    submodule {
      options = {
        module = mkOption {
          description = "the example must be a NixOS module in a file";
          type = pathInStore;
        };
        description = mkOption {
          description = "description of the example, ideally with further instructions on how to use it";
          type = nullOr str;
          default = null;
        };
        tests = mkOption {
          description = "at least one test for the example";
          type = nonEmtpyAttrs (nullOr test);
        };
        links = mkOption {
          description = "links to related resources";
          type = attrsOf link;
          default = { };
        };
      };
    };

  # TODO: make use of modular services https://github.com/NixOS/nixpkgs/pull/372170
  service =
    with types;
    submodule (
      { name, ... }:
      {
        options = {
          name = mkOption {
            type = nullOr str;
            default = name;
          };
          module = mkOption {
            type = moduleType;
          };
          examples = mkOption {
            type = nullOr (attrsOf (nullOr example));
            default = null;
          };
          extensions = mkOption {
            type = nullOr (attrsOf (nullOr plugin));
            default = null;
          };
          links = mkOption {
            type = attrsOf link;
            default = { };
          };
        };
      };
    };

  test = with types; either deferredModule package;
}
