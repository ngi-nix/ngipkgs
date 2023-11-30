{
  lib,
  callPackage,
}: let
  baseDirectory = ./.;

  inherit
    (builtins)
    readDir
    ;

  inherit
    (lib)
    mapAttrs
    concatMapAttrs
    ;

  names = name: type:
    if type != "directory"
    then assert name == "README.md" || name == "default.nix"; {}
    else {${name} = baseDirectory + "/${name}/package.nix";};

  packageFiles = concatMapAttrs names (readDir baseDirectory);

  self =
    mapAttrs (
      _: file:
        callPackage file {}
    )
    packageFiles;
in
  self
