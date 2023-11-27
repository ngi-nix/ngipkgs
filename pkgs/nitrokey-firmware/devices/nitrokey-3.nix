{ lib, rustPlatform, fetchFromGitHub, fetchpatch, cargo-binutils, flip-link, gcc-arm-embedded, llvmPackages, board ? "nk3xn", provisioner ? false, develop ? false }:

rustPlatform.buildRustPackage rec {
  pname = "nitrokey-3-firmware";
  version = "unstable-2022-08-10";

  src = fetchFromGitHub {
    owner = "Nitrokey";
    repo = pname;
    rev = "ffd3524f03d6e8ff66c20ea184a9996a047aeb50";
    sha256 = "sha256-AuG7U33QRTToYwoTNXhzVRI9CyCEvUicIABk/yCwdpo=";
  };

  sourceRoot = "source/runners/lpc55";

  nativeBuildInputs = [ cargo-binutils flip-link gcc-arm-embedded ];

  cargoLock = {
    lockFile = "${src}/runners/lpc55/Cargo.lock";
    outputHashes = {
      "fido-authenticator-0.1.0" = "sha256-sOYuAus1IBFDaD2LGpqENLCtTsaWS90aEqsjjA1Spkg=";
      "trussed-0.1.0" = "sha256-2Gl+f6meuskCM4XkKeHNwKVUu0LhBpyuDyOPvJ/aibM=";
    };
  };

  dontCargoBuild = true;
  dontCargoInstall = true;
  doCheck = false;

  makeFlags = [ "objcopy" "BOARD=${board}" "PROVISIONER=${toString provisioner}" "DEVELOP=${toString develop}" ];

  "CC_thumbv8m.main-none-eabi" = "arm-none-eabi-gcc";
  LIBCLANG_PATH = "${llvmPackages.libclang.lib}/lib";

  installPhase = ''
    runHook preInstall
    mkdir $out
    cp ${if provisioner then "provisioner" else "firmware"}-${board}${lib.optionalString develop "-develop"}.bin $out/
    runHook postInstall
  '';

  meta = with lib; {
    description = "Firmware for the Nitrokey 3 device";
    homepage = "https://github.com/Nitrokey/nitrokey-3-firmware";
    license = with licenses; [ asl20 mit ];
  };
}
