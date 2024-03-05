{
  fetchgit,
  lib,
  stdenv,
  recutils,
  buildGoModule,
}: let
  version = "21-07-2022-unreleased";
in
  buildGoModule rec {
    inherit version;
    pname = "taldir";

    src = fetchgit {
      url = "https://git.taler.net/taldir.git";
      rev = "961875a79149e303af87b1bbb0f1fc717f275dfd";
      hash = "sha256-IMNEPo/a4pAWF5LwuAvVfM0RdEl2ztsfVGODoHNzB9E=";
      leaveDotGit = true;
    };

    preBuild = ''
      mkdir -p internal/gana

      pushd third_party/gana/gnu-taler-error-codes
      make taler_error_codes.go
      popd

      cp third_party/gana/gnu-taler-error-codes/taler_error_codes.go internal/gana/
    '';

    vendorHash = "sha256-SrlFw30S5GAk/7OaCvQfHfppYWKB/7O7jH2z2GURcWw=";

    buildFlags = ["-mod=mod"];

    nativeBuildInputs = [
      recutils
    ];

    patches = [./taler-go-import.patch];

    meta = {
      homepage = "https://git.taler.net/taldir.git";
      description = "Directory service to resolve wallet mailboxes by messenger addresses.";
      license = lib.licenses.agpl3Plus;
    };
  }
