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
      repo = "hyperswarm";
      rev = "v4.7.3";
      sha256 = "sha256-VjRPTsgkc2179ZRS2wAtXlf20jmaPbtyrwcFgG7+N5A=";
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

    npm = nixpkgs.nodejs.pkgs.npm;
  };

  nodejs-package-lock-v3 = {
    packageLockFile = ./package-lock.json;
  };

  name = "hyperswarm";
  version = "v4.7.3";
}
