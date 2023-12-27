{
  lib,
  callPackage,
  dream2nix,
  pkgs,
}: let
  baseDirectory = ./.;

  inherit
    (builtins)
    pathExists
    readDir
    ;

  inherit
    (lib.attrsets)
    mapAttrs
    concatMapAttrs
    ;

  names = name: type:
    if type != "directory"
    then assert name == "README.md" || name == "default.nix"; {}
    else {${name} = baseDirectory + "/${name}";};

  packageDirectories = concatMapAttrs names (readDir baseDirectory);

  callModule = moduleDir: let
    evaluated = lib.evalModules {
      specialArgs = {
        inherit dream2nix;
        packageSets.nixpkgs = pkgs;
      };
      modules = [
        moduleDir
        {
          paths.projectRoot = ../..;
          paths.projectRootFile = "flake.nix";
          paths.package = moduleDir;
          paths.lockFile = "lock.json";
        }
      ];
    };
  in
    evaluated.config.public;

  self =
    mapAttrs (
      _: directory:
        if pathExists (directory + "/package.nix")
        then callPackage (directory + "/package.nix") {}
        else if pathExists (directory + "/dream2.nix")
        then callModule (directory + "/dream2.nix")
        else throw "No package.nix or dream2.nix found in ${directory}"
    )
    packageDirectories;
in
  self
