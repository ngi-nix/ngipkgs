{
  lib,
  stdenv,
  fetchzip,
  fetchFromGitHub,
  nodejs,
  npmHooks,
  fetchNpmDeps,
  tailwindcss_4,
  moreutils,
  jq,
}:
stdenv.mkDerivation (finalAttrs: {
  pname = "pdfding-frontend";
  version = "1.4.0";
  src = fetchFromGitHub {
    owner = "mrmn2";
    repo = "PdfDing";
    tag = "v${finalAttrs.version}";
    hash = "sha256-G2Dzszuau3Z//0ClOJLeuatLZSJBj1uTBJfWt0/x3to=";
  };

  npmDeps = fetchNpmDeps {
    inherit (finalAttrs) src;
    name = "pdfding-frontend-${finalAttrs.version}-npm-deps";
    hash = "sha256-v1NFqDnFcRK8sd0bV3ck+LLMYQ90Dl1R1OnBTwWUVUg=";
  };

  # npm error Invalid package, must have name and version
  postPatch = ''
    ${lib.getExe jq} '. += { "name": "pdfding-frontend", "version": "${finalAttrs.version}" }' package.json \
       | ${lib.getExe' moreutils "sponge"} package.json
  '';

  # TODO pdfjs comes with js source maps, should they be removed in postFetch?
  pdfjs =
    let
      # version from pdfding dockerfile
      # TODO handle in updateScript
      pdfjsVersion = "5.4.296";
    in
    fetchzip {
      url = "https://github.com/mozilla/pdf.js/releases/download/v${pdfjsVersion}/pdfjs-${pdfjsVersion}-dist.zip";
      hash = "sha256-BMWUN2J7GN5J7zwLHr1LIf25T4UmywT9hh1Lm5BqjQA=";
      stripRoot = false;
      postFetch = ''
        rm -rf $out/web/locale \
        $out/web/standard_fonts \
        $out/web/compressed.tracemonkey-pldi-09.pdf
      '';
    };

  nativeBuildInputs = [
    nodejs
    npmHooks.npmConfigHook
    # it is in package.json and thus node_modules but no cli executable
    tailwindcss_4
  ];

  # keeping the file structure same as upstream to minimise confusion
  buildPhase = ''
    runHook preBuild
    mkdir -p $out/pdfding
    cp -r --no-preserve=mode pdfding/static $out/pdfding/static
    cp -r --no-preserve=mode $pdfjs $out/pdfding/static/pdfjs

    tailwindcss -i $out/pdfding/static/css/input.css -o $out/pdfding/static/css/tailwind.css --minify
    rm $out/pdfding/static/css/input.css

    for i in build/pdf.mjs build/pdf.sandbox.mjs build/pdf.worker.mjs web/viewer.mjs; \
    do node_modules/terser/bin/terser $out/pdfding/static/pdfjs/$i --compress -o $out/pdfding/static/pdfjs/$i; done

    npm run build

    cp -r pdfding/static/js $out/pdfding/static

    runHook postBuild
  '';
})
