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
      repo = "hyperbeam";
      rev = "v3.0.1";
      sha256 = "sha256-2JiVJmfhhE4ntb1lTtqqi5RD44hhGGAwnc5Nw0HLBcw=";
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

  name = "hyperbeam";
  version = "v3.0.1";
}
