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
      repo = "hyperblobs";
      rev = "v2.3.3";
      sha256 = "sha256-ybC6X/3zluoIRcoEtUD+zi6u5OWHaRCMPimK1kznIGk=";
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

  name = "hyperblobs";
  version = "v2.3.3";
}
