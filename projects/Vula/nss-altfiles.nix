# not exposed because vula uses specific non-release rev and some build flags
{
  stdenv,
  fetchFromGitHub,
  lib,
}: let
  inherit (lib) licenses maintainers;
in
  stdenv.mkDerivation {
    pname = "nss-altfiles";
    version = "unstable-2020-09-25";

    src = fetchFromGitHub {
      owner = "flatcar";
      repo = "nss-altfiles";
      rev = "9078c543ba7d2bc5011737675b3dddb882673ce7";
      sha256 = "sha256-mkZtuUsahHcwcmXvdH2thhDP7ctT5/wDpd0YUSSfd5w=";
    };

    configureFlags = [
      "--with-types=hosts"
      "--with-module-name='vula'"
      "--datadir=/var/lib/vula-organize/"
    ];

    meta = {
      description = "NSS module for relocating default file locations, tailored for Flatcar Container Linux";
      homepage = "https://github.com/flatcar/nss-altfiles";
      license = licenses.lgpl21Only;
      maintainers = with maintainers; [mightyiam];
    };
  }
