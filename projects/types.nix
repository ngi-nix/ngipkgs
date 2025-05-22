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
rec {
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
          type = deferredModule;
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

  # TODO: port modular services to programs
  program =
    with types;
    submodule (
      { name, ... }:
      {
        options = {
          name = mkOption {
            type = with types; nullOr str;
            default = name;
          };
          module = mkOption {
            type = deferredModule;
          };
          examples = mkOption {
            type = attrsOf (nullOr example);
            default = { };
          };
          extensions = mkOption {
            type = attrsOf (nullOr plugin);
            default = { };
          };
          links = mkOption {
            type = attrsOf link;
            default = { };
          };
        };
      }
    );

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
            type = deferredModule;
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
      }
    );

  test = with types; either deferredModule package;

  projects = mkOption {
    type =
      with types;
      attrsOf (
        submodule (
          { name, ... }:
          {
            options = {
              name = mkOption {
                type = with types; nullOr str;
                default = name;
              };
              metadata = mkOption {
                type =
                  with types;
                  nullOr (submodule {
                    options = {
                      summary = mkOption {
                        type = nullOr str;
                        default = null;
                      };
                      # TODO: convert all subgrants to `subgrant`, remove listOf
                      subgrants = mkOption {
                        type = either (listOf str) subgrant;
                        default = null;
                      };
                      links = mkOption {
                        type = attrsOf link;
                        default = { };
                      };
                    };
                  });
                default = null;
              };
              binary = mkOption {
                type = with types; attrsOf binary;
                default = { };
              };
              nixos = mkOption {
                type =
                  with types;
                  submodule {
                    options = {
                      modules.services = mkOption {
                        type = nullOr (attrsOf (nullOr service));
                        default = null;
                      };
                      modules.programs = mkOption {
                        type = nullOr (attrsOf (nullOr program));
                        default = null;
                      };
                      # An application component may have examples using it in isolation,
                      # but examples may involve multiple application components.
                      # Having examples at both layers allows us to trace coverage more easily.
                      # If this tends to be too cumbersome for package authors and we find a way obtain coverage information programmatically,
                      # we can still reduce granularity and move all examples to the application level.
                      examples = mkOption {
                        type = nullOr (attrsOf example);
                        default = null;
                      };
                      # TODO: Tests should really only be per example, in order to clarify that we care about tested examples more than merely tests.
                      #       But reality is such that most NixOS tests aren't based on self-contained, minimal examples, or if they are they can't be extracted easily.
                      #       Without this field, many applications will appear entirely untested although there's actually *some* assurance that *something* works.
                      #       Eventually we want to move to documentable tests exclusively, and then remove this field, but this may take a very long time.
                      tests = mkOption {
                        type = nullOr (attrsOf test);
                        default = null;
                      };
                    };
                  };
              };
            };
          }
        )
      );
  };
}
