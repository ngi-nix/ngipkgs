{
  lib,
  config,
  dream2nix,
  ...
}:
rec {
  name = "corestore-${version}";
  version = "6.15.9";

  imports = [
    dream2nix.modules.dream2nix.nodejs-package-lock-v3
    dream2nix.modules.dream2nix.nodejs-granular-v3
  ];

  mkDerivation = {
    src = config.deps.fetchFromGitHub {
      owner = "holepunchto";
      repo = "corestore";
      rev = "v${version}";
      sha256 = "sha256-18FKwP0XHoq/F8oF8BCLlul/Xb30sd0iOWuiKkzpPLI=";
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

      npm = nixpkgs.nodejs_16.pkgs.npm;
    };

  nodejs-package-lock-v3 = {
    packageLockFile = ./package-lock.json;
  };
}
