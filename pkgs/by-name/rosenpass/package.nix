{
  lib,
  fetchFromGitHub,
  rustPlatform,
  targetPlatform,
  installShellFiles,
  cmake,
  libsodium,
  pkg-config,
}: let
  inherit
    (lib)
    optionalString
    licenses
    maintainers
    ;
in
  rustPlatform.buildRustPackage rec {
    pname = "rosenpass";
    version = "0.2.2";

    src = fetchFromGitHub {
      owner = pname;
      repo = pname;
      rev = "v${version}";
      hash = "sha256-fQIeKGyTkFWUV9M1o256G4U1Os5OlVsRZu+5olEkbD4=";
    };

    cargoHash = "sha256-GyeJCIE60JuZa/NuixDc3gTj9WAOpSReIyVxQqM4tDQ=";

    nativeBuildInputs = [
      cmake # for oqs build in the oqs-sys crate
      pkg-config
      rustPlatform.bindgenHook # for C-bindings in the crypto libs
      installShellFiles
    ];

    buildInputs = [libsodium];

    # nix defaults to building for aarch64 _without_ the armv8-a
    # crypto extensions, but liboqs depends on these
    preBuild = optionalString targetPlatform.isAarch64 ''
      NIX_CFLAGS_COMPILE="$NIX_CFLAGS_COMPILE -march=armv8-a+crypto"
    '';

    postInstall = ''
      installManPage doc/rosenpass.1
    '';

    meta = {
      description = "Build post-quantum-secure VPNs with WireGuard!";
      homepage = "https://rosenpass.eu/";
      license = with licenses; [
        mit
        /*
        or
        */
        asl20
      ];
      maintainers = with maintainers; [wucke13];
      platforms = ["aarch64-darwin" "aarch64-linux" "x86_64-darwin" "x86_64-linux"];
      mainProgram = "rosenpass";
    };
  }
