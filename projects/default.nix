{
  lib,
  pkgs,
  sources,
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
        "models.nix"
      ];
    in
    concatMapAttrs names (readDir baseDirectory);
in
mapAttrs (name: directory: import directory { inherit lib pkgs sources; }) projectDirectories
