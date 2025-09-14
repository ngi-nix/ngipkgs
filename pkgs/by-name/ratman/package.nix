# This is the nixpkgs derivation updated to use the latest Irdest commit. The last
# stable release as of this time (0.7.0) had some issues. The project is also still
# alpha and undergoing many changes.
{
  lib,
  fetchFromGitea,
  fetchNpmDeps,
  installShellFiles,
  pkg-config,
  rustPlatform,
  npmHooks,
  stdenv,
  nodejs,
  udev,
  llvmPackages_19,
}:
rustPlatform.buildRustPackage rec {
  pname = "ratman";
  version = "0-unstable-2025-09-14";

  src = fetchFromGitea {
    domain = "codeberg.org";
    owner = "irdest";
    repo = "irdest";
    rev = "b0e2113b2194e5bbef2d227f2a151fe05db0de44";
    hash = "sha256-q9MO+xfxT5tbiEV3L7qb3LefYS+cWXVFD2BGt8ftoh4=";
  };

  cargoHash = "sha256-Bemqfjm4yeen0c3vVlJxpVW2Tatfvm4dvkAf6SjXGFk=";

  LIBCLANG_PATH = "${llvmPackages_19.libclang}/lib";

  nativeBuildInputs = [
    pkg-config
    rustPlatform.bindgenHook
    installShellFiles
  ];

  buildInputs = [
    llvmPackages_19.libclang
    udev
  ];

  cargoBuildFlags = [
    "-p"
    "ratmand"
    "-p"
    "ratman-tools"
  ];
  cargoTestFlags = cargoBuildFlags;

  dashboard = stdenv.mkDerivation rec {
    pname = "ratman-dashboard";
    inherit version src;
    sourceRoot = "${src.name}/ratman/dashboard";

    npmDeps = fetchNpmDeps {
      name = "${pname}-${version}-npm-deps";
      src = "${src}/ratman/dashboard";
      hash = "sha256-Sj1UMz5Gv5l2IIxXBREDbetRo+FF2M/QpCyf5Ke2c5U=";
    };

    nativeBuildInputs = [
      nodejs
      npmHooks.npmConfigHook
      npmHooks.npmBuildHook
    ];

    npmBuildScript = "build";

    installPhase = ''
      mkdir $out
      cp -r dist/* $out/
    '';
  };

  prePatch = ''
    cp -r ${dashboard} ratman/dashboard/dist
  '';

  meta = {
    description = "Modular decentralised peer-to-peer packet router and associated tools";
    homepage = "https://codeberg.org/irdest/irdest";
    platforms = lib.platforms.unix;
    license = lib.licenses.agpl3Only;
  };
}
