{
  fetchgit,
  lib,
  stdenv,
  jq,
  nodejs,
  nodePackages,
  python3,
  zip,
}: let
  nixpkgs-22_11 = import (fetchTarball {
    url = "https://github.com/NixOS/nixpkgs/archive/nixos-22.11.tar.gz";
    sha256 = "sha256:1xi53rlslcprybsvrmipm69ypd3g3hr7wkxvzc73ag8296yclyll";
  }) {system = "x86_64-linux";};
  pnpm7 = nixpkgs-22_11.nodePackages.pnpm;

  version = "0.9.2";
in
  stdenv.mkDerivation {
    pname = "wallet-core";
    inherit version;

    src = fetchgit {
      url = "https://git.taler.net/wallet-core.git";
      rev = "v${version}";
      hash = "sha256-DTnwj/pkowR1b1+N94pnuLykD2O37Nh8AKhUIzY7NaU=";
    };

    buildInputs = [
      jq
      nodejs
      pnpm7
      python3
      zip
    ];

    configurePhase = ''
      build-system/taler-build-scripts/configure
    '';

    meta = with lib; {
      description = "GNU Taler wallet core";
      homepage = "https://taler.net/en/index.html";
      license = licenses.gpl3;
    };
  }
