{
  fetchgit,
  lib,
  stdenv
}: let
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

    meta = with lib; {
      description = "GNU Taler wallet core";
      homepage = "https://taler.net/en/index.html";
      license = licenses.gpl3;
    };
  }
