{
  fetchFromGitHub,
  lib,
  rustPlatform,
  targetPlatform,

  cmake,
  libclang,
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
    pkg-config
    rustPlatform.bindgenHook
    cmake
  ];

  buildInputs = [
    libclang
    libsodium
  ];

  # liboqs requires quite a lot of stack memory, thus we adjust
  # the default stack size picked for new threads (which is used
  # by `cargo test`) to be _big enough_.
  # Only set this value for the check phase (not as an environment variable for the derivation),
  # because it is only required in this phase.
  preCheck = "RUST_MIN_STACK=${builtins.toString (8 * 1024 * 1024)}"; # 8 MiB
  
  # nix defaults to building for aarch64 _without_ the armv8-a
  # crypto extensions, but liboqs depends on these
  preBuild = lib.optionalString targetPlatform.isAarch
    ''NIX_CFLAGS_COMPILE="$NIX_CFLAGS_COMPILE -march=armv8-a+crypto"'';

  meta = with lib; {
    description = "Rosenpass is a formally verified, post-quantum secure VPN that uses WireGuard to transport the actual data.";
    homepage = "https://rosenpass.eu/";
    license = with licenses; [mit asl20];
    maintainers = with maintainers;
      [
        andresnav
        imincik
        lorenzleutgeb
      ]
      ++ (with (import ../../maintainers/maintainers-list.nix); [augustebaum kubaneko]);
  };
}
