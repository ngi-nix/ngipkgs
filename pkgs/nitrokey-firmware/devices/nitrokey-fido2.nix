{ lib, gcc-arm-embedded, stdenv, fetchFromGitHub, pynitrokey, python3, part ? "release-buildv", release ? true, pages ? 128 }:

stdenv.mkDerivation rec {
  pname = "nitrokey-fido2-firmware";
  version = "2.4.1";

  src = fetchFromGitHub {
    owner = "Nitrokey";
    repo = pname;
    rev = "${version}.nitrokey";
    sha256 = "sha256-7AsnxRf8mdybI6Mup2mV01U09r5C/oUX6fG2ymkkOOo=";
    fetchSubmodules = true;
  };

  postPatch = ''
    substituteInPlace targets/stm32l432/build/common.mk \
      --replace '$(shell git describe --abbrev=0 )' "${version}.nitrokey" \
      --replace '$(shell git describe)' "${version}.nitrokey"

    substituteInPlace targets/stm32l432/Makefile \
      --replace '`git describe --long`' "${version}.nitrokey"

    substituteInPlace fido2/version.mk \
      --replace '$(shell git describe)' "${version}.nitrokey"

    # otherwise firmware_version is defined multiple times
    substituteInPlace fido2/version.h \
      --replace "const version_t firmware_version ;" ""
  '';

  # only gcc-arm-embedded includes libc_nano.a
  nativeBuildInputs = [ gcc-arm-embedded pynitrokey python3 ];

  preBuild = ''
    cd targets/stm32l432
  '';

  makeFlags = [ "${part}" "RELEASE=${toString release}" "PAGES=${toString pages}" ];

  installPhase = ''
    runHook preInstall
    cp -r release $out
    runHook postInstall
  '';

  meta = with lib; {
    description = "Firmware for the Nitrokey FIDO2 device";
    homepage = "https://github.com/Nitrokey/nitrokey-fido2-firmware";
    license = with licenses; [ asl20 mit ];
  };
}
