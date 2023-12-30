{
  lib,
  config,
  dream2nix,
  ...
}: rec {
  name = "autobase";
  version = "1.0.0-alpha.9";

  imports = [
    dream2nix.modules.dream2nix.nodejs-package-lock-v3
    dream2nix.modules.dream2nix.nodejs-granular-v3
  ];

  mkDerivation = {
    src = config.deps.fetchFromGitHub {
      owner = "holepunchto";
      repo = "autobase";
      rev = "v${version}";
      sha256 = "sha256-aKs39/9GG3tRq5UBBDWcz1h64kaCt+1Cru3C4fKv5RU=";
    };

    doCheck = true;
    checkPhase = ''
      npm run test
    '';

    meta = with lib; {
      description = "Autobase lets you write concise multiwriter data structures with Hypercore";
      homepage = "https://github.com/holepunchto/autobase";
      license = licenses.mit;
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
}
