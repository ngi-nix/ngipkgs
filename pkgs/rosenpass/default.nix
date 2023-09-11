{
  lib,
  fetchFromGitHub,
  rustPlatform,
  targetPlatform,
  cmake,
  libsodium,
  pkg-config,
}:
rustPlatform.buildRustPackage rec {
  pname = "rosenpass";
  version = "0.2.0";
  src = fetchFromGitHub {
    owner = pname;
    repo = pname;
    rev = "v${version}";
    hash = "sha256-r7/3C5DzXP+9w4rp9XwbP+/NK1axIP6s3Iiio1xRMbk=";
  };

  cargoHash = "sha256-g2w3lZXQ3Kg3ydKdFs8P2lOPfIkfTbAF0MhxsJoX/E4=";

  nativeBuildInputs = [
    cmake # for oqs build in the oqs-sys crate
    pkg-config # let libsodium-sys-stable find libsodium
    rustPlatform.bindgenHook # for C-bindings in the crypto libs
  ];

  buildInputs = [ libsodium ];

  # liboqs requires quite a lot of stack memory, thus we adjust
  # Increase the default stack size picked for new threads (which is used
  # by `cargo test`) to be _big enough_.
  # Only set this value for the check phase (not as an environment variable for the derivation),
  # because it is only required in this phase.
  preCheck = "export RUST_MIN_STACK=${builtins.toString (8 * 1024 * 1024)}"; # 8 MiB

  # nix defaults to building for aarch64 _without_ the armv8-a
  # crypto extensions, but liboqs depends on these
  preBuild = lib.optionalString targetPlatform.isAarch
    ''NIX_CFLAGS_COMPILE="$NIX_CFLAGS_COMPILE -march=armv8-a+crypto"'';

  preInstall = "install -D doc/rosenpass.1 $out/share/man/man1/rosenpass.1";

  meta = with lib; {
    description = "Build post-quantum-secure VPNs with WireGuard!";
    homepage = "https://rosenpass.eu/";
    license = with licenses; [ mit /* or */ asl20 ];
    maintainers = with maintainers; [ wucke13 ];
    platforms = platforms.all;
  };
}
