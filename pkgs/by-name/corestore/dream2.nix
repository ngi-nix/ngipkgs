{
  lib,
  config,
  dream2nix,
  ...
}:
rec {
  name = "corestore-${version}";
  version = "7.1.0";

  imports = [
    dream2nix.modules.dream2nix.nodejs-package-lock-v3
    dream2nix.modules.dream2nix.nodejs-granular-v3
  ];

  mkDerivation = {
    src = config.deps.fetchFromGitHub {
      owner = "holepunchto";
      repo = "corestore";
      rev = "v${version}";
      sha256 = "sha256-lbbjYWJah1A2/ySBTI2Mg78dRjLyt/TJ5rhqBPxWOps=";
    };

    doCheck = true;
    checkPhase = ''
      npm run test
    '';

    meta = with lib; {
      description = "A simple corestore that wraps a random-access-storage module";
      homepage = "https://github.com/holepunchto/corestore";
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

      npm = nixpkgs.nodejs_22.pkgs.npm;
    };

  nodejs-package-lock-v3 = {
    packageLockFile = ./package-lock.json;
  };
}
