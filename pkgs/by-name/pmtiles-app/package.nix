{
  lib,
  buildNpmPackage,
  fetchFromGitHub,
  nix-update-script,
}:

buildNpmPackage (finalAttrs: {
  pname = "pmtiles-app";
  version = "0-unstable-2025-01-06";

  src = fetchFromGitHub {
    owner = "protomaps";
    repo = "PMTiles";
    rev = "754e15bf58fa3cd1491bbfd16d48d72a72602596"; # main branch as of 2025-01-06
    hash = "sha256-RtDSUZeW3tIQQNftGzMjPF8srx4hw8ZWV5oJNCYeBig=";
  };

  sourceRoot = "${finalAttrs.src.name}/app";

  npmDepsHash = "sha256-VLNkcBtwXBe1nqA1qlt9DOj3DiAtUwgyXRpHX16cfHs=";

  installPhase = ''
    runHook preInstall
    mkdir -p $out/share/pmtiles-app
    cp -r dist/* $out/share/pmtiles-app/
    runHook postInstall
  '';

  passthru.updateScript = nix-update-script {
    extraArgs = [ "--version=branch" ];
  };

  meta = {
    description = "Web viewer for PMTiles";
    homepage = "https://protomaps.com/docs/pmtiles";
    license = lib.licenses.bsd3;
    maintainers = with lib.maintainers; [ ];
    platforms = lib.platforms.all;
  };
})
