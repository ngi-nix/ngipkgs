{
  lib,
  config,
  dream2nix,
  ...
}:
rec {
  name = "hyperswarm-${version}";
  version = "4.11.1";

  imports = [
    dream2nix.modules.dream2nix.nodejs-package-lock-v3
    dream2nix.modules.dream2nix.nodejs-granular-v3
  ];

  mkDerivation = {
    src = config.deps.fetchFromGitHub {
      owner = "holepunchto";
      repo = "hyperswarm";
      rev = "v${version}";
      sha256 = "1rvyh6xnymhhz2hwk0n5bi0r4j4s703gxd7671x16sz8jykkcnzf";
    };

    # We don't know why tests only fail on CI
    doCheck = false;

    meta = with lib; {
      description = "A distributed networking stack for connecting peers.";
      homepage = "https://github.com/holepunchto/hyperswarm";
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

      npm = nixpkgs.nodejs.pkgs.npm;
    };

  nodejs-package-lock-v3 = {
    packageLockFile = ./package-lock.json;
  };
}
