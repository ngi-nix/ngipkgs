{
  lib,
  rustPlatform,
  fetchgit,
  unstableGitUpdater,
}:
let
  inherit (lib)
    licenses
    ;
in
rustPlatform.buildRustPackage {
  pname = "wireguard-rs";
  version = "0-unstable-2021-01-13";

  src = fetchgit {
    url = "https://git.zx2c4.com/wireguard-rs";
    rev = "7d84ef9064559a29b23ab86036f7ef62b450f90c";
    hash = "sha256-UlT0c0J4oY+E1UM2ElueHECjrxErIBERwiF1huLvtds=";
  };

  cargoLock.lockFile = ./Cargo.lock;

  postPatch = ''
    substituteInPlace Cargo.toml \
      --replace-fail 'pnet = "^0.27"' 'pnet = "^0.29"'
    cp ${./Cargo.lock} Cargo.lock
  '';

  passthru.updateScript = unstableGitUpdater { };

  meta = {
    homepage = "https://git.zx2c4.com/wireguard-rs";
    description = "Rust implementation of WireGuard";
    license = licenses.mit;
    mainProgram = "wireguard-rs";
  };
}
