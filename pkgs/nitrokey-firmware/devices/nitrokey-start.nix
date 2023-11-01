{ lib, stdenv, fetchFromGitHub }:

stdenv.mkDerivation rec {
  pname = "nitrokey-start-firmware";
  version = "12";

  src = fetchFromGitHub {
    owner = "Nitrokey";
    repo = pname;
    rev = "RTM.${version}";
    sha256 = "sha256-7vFAp+rYvIcq2tfNha94YsYvQPqMgBVk2OYGoHxbdNQ=";
    fetchSubmodules = true;
  };

  sourceRoot = "source/src";

  postPatch = ''
    patchShebangs configure
  '';

  configurePlatforms = [ ]; # otherwise additional arguments are added to configureFlags
  # from release/Makefile
  configureFlags = [
    "--target=NITROKEY_START-g"
    "--vidpid=20a0:4211"
    "--enable-factory-reset"
    "--enable-certdo"
  ];

  enableParallelBuilding = true;

  installPhase = ''
    runHook preInstall
    mkdir $out
    cp build/gnuk.{bin,hex} $out/
    runHook postInstall
  '';

  meta = with lib; {
    description = "Firmware for the Nitrokey Start device";
    homepage = "https://github.com/Nitrokey/nitrokey-start-firmware";
    license = licenses.gpl3Plus;
  };
}
