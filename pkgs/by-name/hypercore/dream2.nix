{
  lib,
  config,
  dream2nix,
  ...
}:
rec {
  name = "hypercore-${version}";
  version = "11.1.2";

  imports = [
    dream2nix.modules.dream2nix.nodejs-package-lock-v3
    dream2nix.modules.dream2nix.nodejs-granular-v3
  ];

  mkDerivation = {
    src = config.deps.fetchFromGitHub {
      owner = "holepunchto";
      repo = "hypercore";
      rev = "v${version}";
      sha256 = "sha256-RTYeaJQ88m2be8pxuumVrDde1L5u98NeTHkZ9EN59wI=";
    };

    doCheck = false;
    checkPhase = ''
      npm run test
    '';

    meta = with lib; {
      description = "Hypercore is a secure, distributed append-only log.";
      homepage = "https://github.com/holepunchto/autobase";
      license = licenses.mit;
    };
  };

  deps =
    { nixpkgs, ... }:
    {
      inherit (nixpkgs)
        fetchFromGitHub
        stdenv
        ;

      npm = nixpkgs.nodejs_16.pkgs.npm;
    };

  nodejs-package-lock-v3 = {
    packageLockFile = ./package-lock.json;
  };
}
