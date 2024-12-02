{
  lib,
  config,
  dream2nix,
  ...
}:
rec {
  name = "hyperblobs-${version}";
  version = "2.3.3";

  imports = [
    dream2nix.modules.dream2nix.nodejs-package-lock-v3
    dream2nix.modules.dream2nix.nodejs-granular-v3
  ];

  mkDerivation = {
    src = config.deps.fetchFromGitHub {
      owner = "holepunchto";
      repo = "hyperblobs";
      rev = "v${version}";
      sha256 = "sha256-ybC6X/3zluoIRcoEtUD+zi6u5OWHaRCMPimK1kznIGk=";
    };

    doCheck = true;
    checkPhase = ''
      npm run test
    '';

    meta = with lib; {
      description = "A blob store for Hypercore";
      homepage = "https://github.com/holepunchto/hyperblobs";
      license = licenses.asl20;
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
