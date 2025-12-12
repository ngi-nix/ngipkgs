{
  lib,
  pkgs,
  dream2nix,
  sources,
}:
let
  inherit (builtins)
    elem
    pathExists
    readDir
    ;

  inherit (lib.attrsets)
    concatMapAttrs
    mapAttrs
    ;

  baseDirectory = ./.;

  packageDirectories =
    let
      names =
        name: type:
        if type == "directory" then
          { ${name} = baseDirectory + "/${name}"; }
        # nothing else should be kept in this directory reserved for derivations
        else
          assert elem name allowedFiles;
          { };
      allowedFiles = [
        "README.md"
        "default.nix"
      ];
    in
    concatMapAttrs names (readDir baseDirectory);

  callModule =
    module:
    let
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

  callPackage = pkgs.newScope (self // { inherit callPackage; });

  mkSbtDerivation =
    x:
    import sources.sbt-derivation (
      x
      // {
        inherit pkgs;
        overrides = {
          sbt = pkgs.sbt.override {
            jre = pkgs.jdk17_headless;
          };
        };
      }
    );

  self = mapAttrs (
    _: directory:
    if pathExists (directory + "/package.nix") then
      callPackage (directory + "/package.nix") { }
    else if pathExists (directory + "/dream2.nix") then
      callModule (directory + "/dream2.nix")
    else if pathExists (directory + "/sbt-derivation.nix") then
      callPackage (directory + "/sbt-derivation.nix") {
        inherit mkSbtDerivation;
      }
    else
      throw "No package.nix, dream2.nix or sbt-derivation.nix found in ${directory}"
  ) packageDirectories;
in
self
