{
  lib,
  rustPlatform,
  fetchFromGitHub,
  cargo-binutils,
  flip-link,
  gcc-arm-embedded,
  llvmPackages,
  python3,
  board ? "nk3xn",
}:
rustPlatform.buildRustPackage rec {
  pname = "nitrokey-3-firmware";
  version = "1.5.0";

  src = fetchFromGitHub {
    owner = "Nitrokey";
    repo = pname;
    rev = "v${version}";
    sha256 = "sha256-ATY5RRXHcP/7rp9lVo8LFGPxfCvcr+ljmLXvmhtFic0=";
  };

  nativeBuildInputs = [
    cargo-binutils
    flip-link
    gcc-arm-embedded
    (python3.withPackages (ps: [ps.toml]))
  ];

  cargoLock = {
    lockFile = ./Cargo.lock;
    outputHashes = {
      "admin-app-0.1.0" = "sha256-JVdNLIeuiugMLfApQMDa4MW/ajxRK8V6urN+dukwUTY=";
      "ctap-types-0.1.2" = "sha256-9r4eKQ+y3nnUHtrfcvUkKvl2BoEv+oh86mKwTDlfLmo=";
      "ctaphid-dispatch-0.1.1" = "sha256-UsfvqHUPa5iQc88+kCw5NIcavcBJ76gNM5A4QmnHrOU=";
      "encrypted_container-0.1.0" = "sha256-USjqWyWXAHWuyrEojFe+bBVpfKFSdKN7+TJ6hetZJ8g=";
      "fido-authenticator-0.1.1" = "sha256-BV6hlwGZ5UX6joGP/c/ocBGYqWcDR2GMPGgwIO7AIo4=";
      "interchange-0.3.0" = "sha256-6smrdMMHQEjvZn19njkk45t+GYnvdF3pbqc1s4mQbQY=";
      "iso7816-0.1.1" = "sha256-nkUtcI3o2LGO5EX2MqCZJwUhxUBC2T+w/+vWc4WU4I8=";
      "lpc55-hal-0.3.0" = "sha256-8EDsdDxR3p1ez0b9B1AwHX6B8WDYioEFuKaxodwNQak=";
      "opcard-1.1.0" = "sha256-JLV6gt7PIOYiTxqa8vndxU7cvH/jC9fVJDq7qY3EBr0=";
      "piv-authenticator-0.2.0" = "sha256-KSTa/2UUYoVmxEjo7+Q4GxYPIIpdqkkh0aVQL5D5eWU=";
      "trussed-0.1.0" = "sha256-LYOn77sgeFRFC6N2HKVbZFWltjkieoTT6jq6i8KrfD0=";
      "trussed-auth-0.2.2" = "sha256-jxDPcFWYABkRooHXmIrnVSfSv0G3VhOcklqvftZamMk=";
      "trussed-rsa-alloc-0.1.0" = "sha256-HqBvUGzCam+qzRLWVlWmvdfXwMIpHFInv149KT391yU=";
      "trussed-staging-0.1.0" = "sha256-4+RqGjGLzUrjZJINgRng8OkWw38UPvgYbo6gL8POWnY=";
      "trussed-usbip-0.0.1" = "sha256-52LlS0z16HmAdw89eVZB7Gamr673zUbIJyMoK5B+U8E=";
      "usbd-ctaphid-0.1.0" = "sha256-CXZkQsDS7ZyxeCS6y9VmdKZ7As92gI6cBAMHXdgSFBw=";
    };
  };

  dontCargoBuild = true;
  dontCargoInstall = true;
  doCheck = false;

  makeFlags = ["build-${board}"];

  preBuild = ''
    build_dir=$(mktemp -d)
    cp -R $src/* $build_dir/
    chmod -R +w $build_dir
    cd $build_dir/runners/embedded
  '';

  "CC_thumbv8m.main-none-eabi" = "arm-none-eabi-gcc";
  LIBCLANG_PATH = "${llvmPackages.libclang.lib}/lib";

  installPhase = ''
    runHook preInstall
    cp -r artifacts $out
    runHook postInstall
  '';

  meta = with lib; {
    description = "Firmware for the Nitrokey 3 device";
    homepage = "https://github.com/Nitrokey/nitrokey-3-firmware";
    license = with licenses; [asl20 mit];
  };
}
