{
  stdenv,
  fetchgit,
}: let
  version = "0.9.2";
in
  stdenv.mkDerivation {
    pname = "wallet-core";
    inherit version;

    src = fetchgit {
      url = "https://git.taler.net/wallet-core.git";
      rev = "v${version}";
      hash = "";
    };

    meta = {};
  }
