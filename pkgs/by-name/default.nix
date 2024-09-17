{
  pkgs,
  lib,
  dream2nix,
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

  packageDirectories = let
    names = name: type:
      if type == "directory"
      then {${name} = baseDirectory + "/${name}";}
      # nothing else should be kept in this directory reserved for derivations
      else assert name == "README.md" || name == "default.nix"; {};
  in
    concatMapAttrs names (readDir baseDirectory);

  callModule = module: let
    evaluated = lib.evalModules {
      specialArgs = {
        inherit dream2nix;
        packageSets.nixpkgs = pkgs;
      };
      modules = [
        module
        {
          paths.projectRoot = ../..;
          paths.projectRootFile = "flake.nix";
          paths.package = module;
          paths.lockFile = "lock.json";
        }
      ];
    };
  in
    evaluated.config.public;

  callPackage = pkgs.newScope (
    self // {inherit callPackage;}
  );

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
