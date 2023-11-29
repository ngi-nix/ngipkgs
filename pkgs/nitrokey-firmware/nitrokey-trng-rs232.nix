{
  lib,
  stdenvAvr,
  fetchFromGitHub,
}:
stdenvAvr.mkDerivation rec {
  pname = "nitrokey-trng-rs232-firmware";
  version = "1.0.0";

  src = fetchFromGitHub {
    owner = "Nitrokey";
    repo = pname;
    rev = "v${version}";
    hash = "sha256-vY/9KAGB6lTkkjW9zUiHA3wD2d35cEBVBTr12bHCy4k=";
  };

  sourceRoot = "source/src";

  makeFlags = ["all"];

  installPhase = ''
    runHook preInstall
    install -D TRNGSerial.bin $out/TRNGSerial.bin
    runHook postInstall
  '';

  meta = with lib; {
    description = "Firmware for the Nitrokey TRNG RS232 device";
    homepage = "https://github.com/Nitrokey/nitrokey-trng-rs232-firmware";
    license = licenses.gpl3Plus;
  };
}
