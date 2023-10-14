{
  lib,
  config,
  dream2nix,
  ...
}: {
  imports = [
    dream2nix.modules.dream2nix.nodejs-package-lock-v3
    dream2nix.modules.dream2nix.nodejs-granular-v3
  ];

  mkDerivation = {
    src = config.deps.fetchFromGitHub {
      owner = "holepunchto";
      repo = "corestore";
      rev = "v6.15.9";
      sha256 = "sha256-18FKwP0XHoq/F8oF8BCLlul/Xb30sd0iOWuiKkzpPLI=";
    };

    doCheck = true;
    checkPhase = ''
      npm run test
    '';
  };

  deps = {nixpkgs, ...}: {
    inherit
      (nixpkgs)
      fetchFromGitHub
      stdenv
      ;

    npm = nixpkgs.nodejs_16.pkgs.npm;
  };

  nodejs-package-lock-v3 = {
    packageLockFile = ./package-lock.json;
  };

  name = "corestore";
  version = "v6.15.9";
}
