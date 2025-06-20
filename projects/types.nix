{
  lib,
  ...
}:
let
  inherit (lib)
    types
    mkOption
    ;

  types' = {
    metadata =
      with types;
      submodule {
        options = {
          summary = mkOption {
            type = nullOr str;
            default = null;
          };
          # TODO: convert all subgrants to `subgrant`, remove listOf
          subgrants = mkOption {
            type = either (listOf str) types'.subgrant;
            default = null;
          };
          links = mkOption {
            type = attrsOf types'.link;
            default = { };
          };
        };
      };

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

    # TODO: port modular services to programs
    program =
      with types;
      submodule (
        { name, ... }:
        {
          options = {
            name = mkOption {
              type = str;
              default = name;
            };
            module = mkOption {
              type = nullOr deferredModule;
            };
            examples = mkOption {
              type = attrsOf (nullOr types'.example);
              default = { };
            };
            extensions = mkOption {
              type = attrsOf (nullOr types'.plugin);
              default = { };
            };
            links = mkOption {
              type = attrsOf types'.link;
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
              type = str;
              default = name;
            };
            module = mkOption {
              type = nullOr deferredModule;
            };
            examples = mkOption {
              type = nullOr (attrsOf (nullOr types'.example));
              default = null;
            };
            extensions = mkOption {
              type = nullOr (attrsOf (nullOr types'.plugin));
              default = null;
            };
            links = mkOption {
              type = attrsOf types'.link;
              default = { };
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
            type = types'.nonEmtpyAttrs (nullOr types'.test);
          };
          links = mkOption {
            description = "links to related resources";
            type = attrsOf types'.link;
            default = { };
          };
        };
      };

    demo = types.submodule {
      options = {
        inherit (types'.example.getSubOptions { })
          module
          tests
          description
          links
          ;
        problem = mkOption {
          type = types.nullOr types'.problem;
          default = null;
          example = {
            problem.broken = {
              reason = "Does not work as intended. Needs fixing.";
            };
          };
        };
      };
    };

    problem = types.attrTag {
      broken = mkOption {
        type = types.submodule {
          options.reason = mkOption {
            type = types.str;
          };
        };
      };
    };

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
                  type = str;
                  default = name;
                };
                metadata = mkOption {
                  type = with types; nullOr types'.metadata;
                  default = null;
                };
                binary = mkOption {
                  type = with types; attrsOf types'.binary;
                  default = { };
                };
                nixos = mkOption {
                  type =
                    with types;
                    submodule {
                      options = {
                        modules.programs = mkOption {
                          type = nullOr (attrsOf (nullOr types'.program));
                          default = null;
                        };
                        modules.services = mkOption {
                          type = nullOr (attrsOf (nullOr types'.service));
                          default = null;
                        };
                        demo = mkOption {
                          type = nullOr (attrTag {
                            vm = mkOption { type = types'.demo; };
                            shell = mkOption { type = types'.demo; };
                          });
                          default = null;
                        };
                        # An application component may have examples using it in isolation,
                        # but examples may involve multiple application components.
                        # Having examples at both layers allows us to trace coverage more easily.
                        # If this tends to be too cumbersome for package authors and we find a way obtain coverage information programmatically,
                        # we can still reduce granularity and move all examples to the application level.
                        examples = mkOption {
                          type = nullOr (attrsOf types'.example);
                          default = null;
                        };
                        # TODO: Tests should really only be per example, in order to clarify that we care about tested examples more than merely tests.
                        #       But reality is such that most NixOS tests aren't based on self-contained, minimal examples, or if they are they can't be extracted easily.
                        #       Without this field, many applications will appear entirely untested although there's actually *some* assurance that *something* works.
                        #       Eventually we want to move to documentable tests exclusively, and then remove this field, but this may take a very long time.
                        tests = mkOption {
                          type = nullOr (attrsOf types'.test);
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
  };
in
types'
