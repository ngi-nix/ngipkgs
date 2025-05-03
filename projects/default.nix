{
  lib,
  pkgs,
  sources,
  models ? import ./models.nix {
    inherit lib pkgs;
    sources = sources.inputs;
  },
}:
let
  inherit (builtins)
    elem
    readDir
    trace
    ;

  inherit (lib.attrsets)
    concatMapAttrs
    mapAttrs
    filterAttrs
    ;

  inherit (models)
    project
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
      allowedFiles =
        [
          "README.md"
          "default.nix"
          "models.nix"
        ]
        # TODO: remove after fully migrating types to the module system
        ++ [
          "default-module.nix"
          "types.nix"
        ];
    in
    # TODO: use fileset and filter for `gitTracked` files
    concatMapAttrs names (readDir baseDirectory);
in
mapAttrs (
  name: directory: project (import directory { inherit lib pkgs sources; })
) projectDirectories
