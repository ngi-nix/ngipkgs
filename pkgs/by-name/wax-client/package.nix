{
  lib,
  stdenv,
  fetchFromGitHub,
  fetchYarnDeps,
  yarnConfigHook,
  yarnBuildHook,
  yarnInstallHook,
  nodejs,
  makeWrapper,
  nodePackages,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "wax-client";
  version = "0-unstable-2025-08-14";

  src = fetchFromGitHub {
    owner = "Wax-Platform";
    repo = "Wax";
    rev = "01316b557d201b09b4ce9745c7d7e841d94b8268";
    hash = "sha256-afc15miIzzEBRrzvJaRzSK+IWe4/36+Lvo7IbmNM2CA=";
  };

  sourceRoot = "${finalAttrs.src.name}/packages/client";

  yarnOfflineCache = fetchYarnDeps {
    yarnLock = "${finalAttrs.src}/packages/client/yarn.lock";
    hash = "sha256-ztT3uwlTM+Dz7dzvfExvUc4zLU/SHSYQaKsMUUCGPrA=";
  };

  nativeBuildInputs = [
    yarnConfigHook
    yarnBuildHook
    yarnInstallHook
    nodejs
    makeWrapper
  ];

  # Environment variables for the build (matching Docker setup)
  # https://github.com/Wax-Platform/Wax/blob/main/packages/client/Dockerfile-production
  preBuild = ''
    export NODE_ENV="production"
    export CLIENT_PAGE_TITLE="Wax"
    export CLIENT_FAVICON_PATH="../static/wax.ico"
    export CLIENT_LANGUAGE="en-US"
    export CLIENT_FEATURE_UPLOAD_DOCX_FILES="true"
    export CLIENT_FEATURE_BOOK_STRUCTURE="false"
  '';

  yarnBuildScript = "coko-client-build";

  installPhase = ''
    runHook preInstall

    mkdir -p $out/lib/wax-client
    cp -r _build $out/lib/wax-client/
    cp node_modules/@coko/client/scripts/env.sh $out/lib/wax-client/
    mkdir -p $out/bin

    cat > $out/bin/wax-client << EOF
      ${stdenv.shell}
      cd "$out/lib/wax-client"
      exec sh ./env.sh serve -p 8080 --single ./_build "\$@"
    EOF
    chmod +x $out/bin/wax-client

    runHook postInstall
  '';

  postFixup = ''
    wrapProgram $out/bin/wax-client \
      --prefix PATH : ${lib.makeBinPath [ nodePackages.serve ]} \
  '';

  meta = {
    homepage = "https://github.com/Wax-Platform/Wax";
    description = "Wax Platform web client for collaborative document editing";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ themadbit ];
    teams = with lib.teams; [ ngi ];
    platforms = lib.platforms.all;
    mainProgram = "wax-client";
  };
})
