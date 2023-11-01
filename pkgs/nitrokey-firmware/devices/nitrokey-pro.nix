{ lib, stdenv, fetchFromGitHub, python3, srecord }:

stdenv.mkDerivation rec {
  pname = "nitrokey-pro-firmware";
  version = "0.15";

  src = fetchFromGitHub {
    owner = "Nitrokey";
    repo = pname;
    rev = "v${version}";
    sha256 = "sha256-q+kbEOLA05xR6weAWDA1hx4fVsaN9UNKiOXGxPRfXuI=";
    fetchSubmodules = true;
  };

  postPatch = ''
    substituteInPlace build/gcc/dfu.mk \
      --replace "git submodule update --init --recursive" "" \
      --replace '$(shell git describe)' "v${version}"

    patchShebangs dapboot/libopencm3/scripts
  '';

  nativeBuildInputs = [ python3 srecord ];

  installPhase = ''
    runHook preInstall
    install -D build/gcc/bootloader.hex $out/bootloader.hex
    install -D build/gcc/nitrokey-pro-firmware.hex $out/firmware.hex
    runHook postInstall
  '';

  meta = with lib; {
    description = "Firmware for the Nitrokey Pro device";
    homepage = "https://github.com/Nitrokey/nitrokey-pro-firmware";
    license = licenses.gpl3Plus;
  };
}
