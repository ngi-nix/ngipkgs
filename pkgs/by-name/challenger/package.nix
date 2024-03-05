{
  lib,
  stdenv,
  fetchgit,
  autoreconfHook,
  gnunet,
  jansson,
  libgcrypt,
  libgnurl,
  curlWithGnuTls,
  libmicrohttpd,
  pkg-config,
  postgresql,
  taler-exchange,
  taler-merchant,
  libsodium,
  callPackage,
}: let
  version = "0.9.3";
  gana = fetchgit {
    url = "https://git.gnunet.org/gana.git";
    rev = "c6caa0a91e01b0c74fd71fce71ee5207264a492c";
    sha256 = "sha256-Y/xDgrBRhlyRe2nbQ7FJEgYk2vg7TAdLwyefnAlM8cg=";
  };

  prebuilt = fetchgit {
    url = "https://git.taler.net/docs.git";
    rev = "5e47a72e8a2b5086dfdae4078f695155f5ed7af8";
    sha256 = "sha256-e5g2Hwasnezdp67j/vy2ij54D5l0V6M08ONKYvPG/Xk=";
  };

  te = taler-exchange.overrideAttrs (old: {
    src = fetchgit {
      url = "https://git.taler.net/exchange.git";
      rev = "v${version}";
      sha256 = "sha256-P6YLK/eh5h4a4LV/wTNl1mCwFDBicKlypVceLIvVJgc=";
      fetchSubmodules = false;
    };

    postUnpack = ''
      # ln -sn ${gana}/* $sourceRoot/contrib/gana
      # ln -sn ${prebuilt}/* $sourceRoot/doc/prebuilt
      cp -r ${gana}/* $sourceRoot/contrib/gana
      cp -r ${prebuilt}/* $sourceRoot/doc/prebuilt
    '';
  });
in
  te
