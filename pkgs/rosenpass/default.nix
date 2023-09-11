{
  lib,
  cmake,
  fetchFromGitHub,
  libclang,
  libsodium,
  pkg-config,
  rustPlatform,
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
  # by `cargo test`) to be _big enough_ (8MiB)
  # Only set for the check phase (not as an environment variable for the derivation),
  # because it is only required in that phase.
  preCheck = ''
    export RUST_MIN_STACK=8388608
  '';

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
