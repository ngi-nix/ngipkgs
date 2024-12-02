{
  lib,
  rustPlatform,
  fetchgit,
}:
let
  inherit (lib)
    licenses
    ;
in
rustPlatform.buildRustPackage {
  pname = "wireguard-rs";
  version = "unstable-2021-01-13";

  src = fetchgit {
    url = "https://git.zx2c4.com/wireguard-rs";
    rev = "7d84ef9064559a29b23ab86036f7ef62b450f90c";
    hash = "sha256-UlT0c0J4oY+E1UM2ElueHECjrxErIBERwiF1huLvtds=";
  };

  cargoLock.lockFile = ./Cargo.lock;

  postPatch = ''
    cp ${./Cargo.lock} Cargo.lock
  '';

  meta = {
    homepage = "https://git.zx2c4.com/wireguard-rs";
    description = "Rust implementation of WireGuard";
    license = licenses.mit;
    mainProgram = "wireguard-rs";
  };
}
