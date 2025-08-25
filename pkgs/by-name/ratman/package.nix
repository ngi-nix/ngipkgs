# This is the nixpkgs derivation updated to use the latest Irdest commit. The last
# stable release as of this time (0.7.0) had some issues. The project is also still
# alpha and undergoing many changes.
# There are also a few bug-fix patches applied.
{
  lib,
  fetchFromGitea,
  fetchpatch,
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
  version = "0-unstable-2025-08-24";

  src = fetchFromGitea {
    domain = "codeberg.org";
    owner = "irdest";
    repo = "irdest";
    rev = "6d074d45a9d5e6fefe9a2c9f60e1dedcbd8840a2";
    hash = "sha256-h6XA3UhsvE3V0Ybr9TrbDzMuIIcU6hX6auCBOe+kERk=";
  };

  patches = [
    # https://codeberg.org/irdest/irdest/pulls/269
    ./fix-ratmand-generate-command.patch
    # https://codeberg.org/irdest/irdest/pulls/270
    ./fix-inet-peering.patch
  ];

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

    patches = [
      # https://codeberg.org/irdest/irdest/pulls/268
      (fetchpatch {
        url = "file://${./fix-dashboard-build.patch}";
        relative = "ratman/dashboard";
        hash = "sha256-vN7DjWisDM5JInHMKfg3HCs/C4OPc70RVRsZueTXOig=";
      })
    ];

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
