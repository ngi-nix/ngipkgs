{
  dream2nix,
  pkgs,
}: let
  packages = dream2nix.lib.importPackages {
    projectRoot = ./.;
    projectRootFile = "package.nix";
    packagesDir = ./.;
    packageSets.nixpkgs = pkgs;
  };

  d2nFilesDirName = "d2n-files";
  errorMessage = throw "Missing '${d2nFilesDirName}' folder inside ${builtins.toString ./.}.";
in
  pkgs.lib.attrByPath [d2nFilesDirName] errorMessage packages
