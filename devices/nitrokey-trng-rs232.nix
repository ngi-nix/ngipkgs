{ lib, stdenv, fetchFromGitHub }:

stdenv.mkDerivation rec {
  pname = "nitrokey-trng-rs232-firmware";
  version = "unstable-2022-05-16";

  src = fetchFromGitHub {
    owner = "Nitrokey";
    repo = pname;
    rev = "50c83c93d1e4021695759b2949e6bbfba2e1867e";
    sha256 = "sha256-6B87l56j/a+VJSSt5aNkm3DXjnlQGscKPGV2BM7IKNw=";
  };

  sourceRoot = "source/src";

  postPatch = ''
    rm TRNGSerial.bin
  '';

  makeFlags = [ "all" ];

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
