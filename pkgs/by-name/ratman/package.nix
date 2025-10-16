# This is the nixpkgs derivation updated to use the latest Irdest commit. The last
# stable release as of this time (0.7.0) had some issues. The project is also still
# alpha and undergoing many changes.
{
  lib,
  fetchFromGitea,
  installShellFiles,
  pkg-config,
  rustPlatform,
  buildNpmPackage,
  udev,
  nix-update-script,
}:
rustPlatform.buildRustPackage (finalAttrs: {
  pname = "ratman";
  version = "0.7.0-unstable-2025-09-09";

  src = fetchFromGitea {
    domain = "codeberg.org";
    owner = "irdest";
    repo = "irdest";
    rev = "b0e2113b2194e5bbef2d227f2a151fe05db0de44";
    hash = "sha256-q9MO+xfxT5tbiEV3L7qb3LefYS+cWXVFD2BGt8ftoh4=";
  };

  cargoHash = "sha256-Bemqfjm4yeen0c3vVlJxpVW2Tatfvm4dvkAf6SjXGFk=";

  nativeBuildInputs = [
    pkg-config
    rustPlatform.bindgenHook
    installShellFiles
  ];

  buildInputs = [
    udev
  ];

  cargoBuildFlags = [
    "-p"
    "ratmand"
    "-p"
    "ratman-tools"
  ];
  cargoTestFlags = finalAttrs.cargoBuildFlags;

  dashboard = buildNpmPackage {
    pname = "ratman-dashboard";
    inherit (finalAttrs) version src;
    sourceRoot = "${finalAttrs.src.name}/ratman/dashboard";

    npmDepsHash = "sha256-Sj1UMz5Gv5l2IIxXBREDbetRo+FF2M/QpCyf5Ke2c5U=";

    installPhase = ''
      runHook preInstall

      mkdir $out
      cp -r dist/* $out/

      runHook postInstall
    '';
  };

  prePatch = ''
    cp -r ${finalAttrs.dashboard} ratman/dashboard/dist
  '';

  passthru.updateScript = nix-update-script { extraArgs = [ "--version=branch" ]; };

  meta = {
    description = "Modular decentralised peer-to-peer packet router and associated tools";
    homepage = "https://codeberg.org/irdest/irdest";
    platforms = lib.platforms.unix;
    license = lib.licenses.agpl3Only;
  };
})
