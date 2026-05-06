{
  bun,
  deno,
  fetchFromGitea,
  fetchFromGitHub,
  fetchurl,
  lib,
  makeWrapper,
  nodejs,
  stdenvNoCC,
}:
let
  inherit (stdenvNoCC.hostPlatform) system;
  denoBash = fetchurl {
    name = "bash.ts";
    url = "https://raw.githubusercontent.com/justinawrey/bash/refs/tags/0.2.0/mod.ts";
    hash = "sha256-rPyhsPAkmH8V/xz0etN6SkoMU/QHW2L9lOuRkV30aCM=";
  };
in
stdenvNoCC.mkDerivation (finalAttrs: {
  pname = "cartes";
  version = "3-unstable-2025-12-10";

  src = fetchFromGitea {
    domain = "codeberg.org";
    owner = "cartes";
    repo = "web";
    rev = "8d33e9c70c4e279695663088fe21625fbeb7d3d3";
    hash = "sha256-jDUdm36HIv4szaoBlt23Xtv8X6iLJU6pTxV8EBzvU7M=";
  };

  patches = [
    ./app-icons-fetch.patch
  ];

  postPatch = ''
    substituteInPlace app/icons/fetch.ts \
      --replace-fail 'https://deno.land/x/bash/mod.ts' '${denoBash}'
    substituteInPlace app/sitemap.ts \
      --replace-fail 'generateAgencies = async () => {' 'generateAgencies = async () => { return [];'
    substituteInPlace lib/issues.ts \
      --replace-fail 'downloadIssues() {' 'downloadIssues() { return [];'
  '';

  nativeBuildInputs = [
    bun
    deno
    makeWrapper
  ];

  postConfigure = ''
    cp -r ${finalAttrs.passthru.bunDeps}/node_modules .
    substituteInPlace node_modules/.bin/next \
      --replace-fail "/usr/bin/env node" "${lib.getExe nodejs}"

    export DENO_DIR=$(mktemp -d)
    deno run --allow-all app/icons/fetch.ts
  '';

  buildPhase = ''
    runHook preBuild

    bun run build

    runHook postBuild
  '';

  installPhase = ''
    runHook preInstall

    mkdir -p $out/lib/cartes
    cp -R . $out/lib/cartes/

    mkdir -p $out/bin
    makeWrapper $out/lib/cartes/node_modules/.bin/next $out/bin/cartes \
      --add-flag start

    runHook postInstall
  '';

  env = {
    NIX_USE_PREFETCHED = finalAttrs.passthru.osmand-resources;
  };

  passthru = {
    bunDeps = stdenvNoCC.mkDerivation {
      name = "${finalAttrs.pname}-bun-deps";
      inherit (finalAttrs) src;

      postPatch = ''
        substituteInPlace package.json \
          --replace-fail " deno run " " ${lib.getExe deno} run "
      '';

      buildPhase = ''
        runHook preBuild

        export BUN_INSTALL_CACHE_DIR=$(mktemp -d)
        export DENO_DIR=$(mktemp -d)

        ${lib.getExe bun} install --no-save --frozen-lockfile --no-progress

        runHook postBuild
      '';

      installPhase = ''
        runHook preInstall

        mkdir -p $out
        cp -R node_modules $out/

        runHook postInstall
      '';

      # breaks FOD
      dontPatchShebangs = true;

      outputHash = finalAttrs.passthru.bunDepsHashes.${system} or (throw "Unsupported system: ${system}");
      outputHashAlgo = "sha256";
      outputHashMode = "recursive";
    };
    bunDepsHashes = {
      x86_64-linux = "sha256-6VRnPZ522x89kX2Y4XdAKuXeyZJG3Yz/ldDVBk+bido=";
    };
    osmand-resources = fetchFromGitHub {
      owner = "osmandapp";
      repo = "OsmAnd-resources";
      rev = "8c50e17d79910c60dfcd7a037526a7c0a948ad0f";
      hash = "sha256-/f5VqqLaiGqGRwDQzztyv5CTZxeiy1QUoLaU/7ofZZw=";
    };
  };

  meta = {
    description = "Modern web map application with transit support";
    homepage = "https://cartes.app/";
    downloadPage = "https://codeberg.org/cartes/web";
    license = lib.licenses.agpl3Plus;
    maintainers = with lib.maintainers; [ prince213 ];
    teams = with lib.teams; [ ngi ];
    mainProgram = "cartes";
    platforms = lib.attrNames finalAttrs.passthru.bunDepsHashes;
  };
})
