{
  lib,
  config,
  dream2nix,
  ...
}:
rec {
  name = "hyperbeam-${version}";
  version = "3.0.2";

  imports = [
    dream2nix.modules.dream2nix.nodejs-package-lock-v3
    dream2nix.modules.dream2nix.nodejs-granular-v3
  ];

  mkDerivation = {
    src = config.deps.fetchFromGitHub {
      owner = "holepunchto";
      repo = "hyperbeam";
      rev = "v${version}";
      sha256 = "sha256-g3eGuol3g1yfGHDSzI1wQXMxJudGCt4PHHdmtiRQS/Q=";
    };

    doCheck = true;
    checkPhase = ''
      npm run test
    '';

    meta = with lib; {
      description = "A 1-1 end-to-end encrypted internet pipe powered by Hyperswarm";
      homepage = "https://github.com/holepunchto/hyperbeam";
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
