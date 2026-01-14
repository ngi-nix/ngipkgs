{
  lib,
  nodejs,
  pnpm_9,
  fetchPnpmDeps,
  pnpmConfigHook,
  stdenv,
  atomic-server,
}:

let
  pnpm = pnpm_9;
in
stdenv.mkDerivation rec {
  pname = "atomic-browser";
  inherit (atomic-server) version;
  src = "${atomic-server.src}/browser";

  pnpmDeps = fetchPnpmDeps {
    inherit src pname;
    inherit pnpm;
    fetcherVersion = 3;
    hash = "sha256-1rlBZKmuXp8kSyh6EbCjGYpQFTGc0y1Z/SLwK+xNNwc=";
  };

  nativeBuildInputs = [
    nodejs
    pnpm
    pnpmConfigHook
  ];

  postBuild = ''
    pnpm run build
  '';

  installPhase = ''
    runHook preInstall

    cp -R ./data-browser/dist/ $out/

    runHook postInstall
  '';

  meta = {
    description = "A GUI for viewing, editing and browsing Atomic Data";
    homepage = "https://github.com/atomicdata-dev/atomic-server/tree/develop/browser";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ ];
  };
}
