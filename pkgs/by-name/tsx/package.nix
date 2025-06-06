{
  lib,
  stdenvNoCC,
  fetchFromGitHub,
  fetchNpmDeps,
  nodejs,
  pnpm,
}:

stdenvNoCC.mkDerivation (finalAttrs: {
  pname = "tsx";
  version = "4.19.4";

  src = fetchFromGitHub {
    owner = "privatenumber";
    repo = "tsx";
    tag = "v${finalAttrs.version}";
    hash = "sha256-+GJWyhUxkmCtEoq25ANXKmF7pO1BrndvtuP0i8jusVI=";
  };

  pnpmDeps = pnpm.fetchDeps {
    inherit (finalAttrs) pname version src;
    # TODO this might be flaky?
    hash = "sha256-7449ljF5TlLoAyDm+M74Y/CbEV7ehBFCJcxizR2myyU=";
  };

  strictDeps = true;

  nativeBuildInputs = [
    nodejs
    pnpm.configHook
  ];

  buildInputs = [
    nodejs
  ];

  buildPhase = ''
    runHook preBuild

    pnpm build

    runHook postBuild
  '';

  installPhase = ''
    runHook preInstall

    mkdir -p $out/{bin,share/tsx}
    cp -r dist docs node_modules $out/share/tsx/

    ln -s $out/share/tsx/dist/cli.mjs $out/bin/tsx

    runHook postInstall
  '';

  meta = {
    description = "TypeScript Execute, Node.js enhanced with esbuild to run TypeScript & ESM files";
    homepage = "https://tsx.is";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ ];
    platforms = lib.platforms.all;
  };
})
