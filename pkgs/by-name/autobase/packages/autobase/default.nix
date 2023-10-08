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
      repo = "autobase";
      rev = "v1.0.0-alpha.9";
      sha256 = "sha256-aKs39/9GG3tRq5UBBDWcz1h64kaCt+1Cru3C4fKv5RU=";
    };
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

  name = "autobase";
  version = "v1.0.0-alpha.9";
}
