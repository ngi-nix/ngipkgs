{
  lib,
  pkgs,
  sources,
  types' ? import ./types.nix { inherit lib; },
}:
let
  inherit (builtins)
    elem
    readDir
    trace
    ;

  inherit (lib)
    types
    mkOption
    ;

  inherit (lib.attrsets)
    concatMapAttrs
    mapAttrs
    ;

  baseDirectory = ./.;

  projectDirectories =
    let
      names =
        name: type:
        if type == "directory" then
          { ${name} = baseDirectory + "/${name}"; }
        # nothing else should be kept in this directory reserved for projects
        else
          assert elem name allowedFiles;
          { };
      allowedFiles = [
        "README.md"
        "default.nix"
        "types.nix"
      ];
    in
    # TODO: use fileset and filter for `gitTracked` files
    concatMapAttrs names (readDir baseDirectory);
in
{
  options.projects = mkOption {
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
                description = ""; # TODO:
              };
              metadata = mkOption {
                type =
                  with types;
                  nullOr (submodule {
                    options = {
                      summary = mkOption {
                        type = nullOr str;
                        default = null;
                        description = ""; # TODO:
                      };
                      # TODO: convert all subgrants to `subgrant`, remove listOf
                      subgrants = mkOption {
                        type = either (listOf str) types'.subgrant;
                        default = null;
                        description = ""; # TODO:
                      };
                      links = mkOption {
                        type = attrsOf types'.link;
                        default = { };
                        description = ""; # TODO:
                      };
                    };
                  });
                default = null;
                description = ""; # TODO:
              };
              binary = mkOption {
                type = with types; attrsOf types'.binary;
                default = { };
                description = ""; # TODO:
              };
              nixos = mkOption {
                type =
                  with types;
                  submodule {
                    options = {
                      services = mkOption {
                        type = nullOr (attrsOf (nullOr types'.service));
                        default = null;
                        description = ""; # TODO:
                      };
                      programs = mkOption {
                        type = nullOr (attrsOf (nullOr types'.program));
                        default = null;
                        description = ""; # TODO:
                      };
                      # An application component may have examples using it in isolation,
                      # but examples may involve multiple application components.
                      # Having examples at both layers allows us to trace coverage more easily.
                      # If this tends to be too cumbersome for package authors and we find a way obtain coverage information programmatically,
                      # we can still reduce granularity and move all examples to the application level.
                      examples = mkOption {
                        type = nullOr (attrsOf types'.example);
                        default = null;
                        description = ""; # TODO:
                      };
                      # TODO: Tests should really only be per example, in order to clarify that we care about tested examples more than merely tests.
                      #       But reality is such that most NixOS tests aren't based on self-contained, minimal examples, or if they are they can't be extracted easily.
                      #       Without this field, many applications will appear entirely untested although there's actually *some* assurance that *something* works.
                      #       Eventually we want to move to documentable tests exclusively, and then remove this field, but this may take a very long time.
                      tests = mkOption {
                        type = nullOr (attrsOf types'.test);
                        default = null;
                        description = ""; # TODO:
                      };
                    };
                  };
                description = ""; # TODO:
              };
            };
          }
        )
      );
    description = ""; # TODO:
  };

  config.projects = mapAttrs (
    name: directory: import directory { inherit lib pkgs sources; }
  ) projectDirectories;
}
