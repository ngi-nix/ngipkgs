{
  lib,
  config,
  dream2nix,
  ...
}:
rec {
  name = "corestore-${version}";
  version = "7.0.23";

  imports = [
    dream2nix.modules.dream2nix.nodejs-package-lock-v3
    dream2nix.modules.dream2nix.nodejs-granular-v3
  ];

  mkDerivation = {
    src = config.deps.fetchFromGitHub {
      owner = "holepunchto";
      repo = "corestore";
      rev = "v${version}";
      sha256 = "sha256-oAsyv10BcmInvlZMzc/vJEJT9r+q/Rosm19EyblIDCM=";
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

      # Update to Node.js 22
      npm = nixpkgs.nodejs_16.pkgs.npm;
    };

  nodejs-package-lock-v3 = {
    packageLockFile = ./package-lock.json;
  };
}
