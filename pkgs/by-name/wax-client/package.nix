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

  # Build the client (equivalent to 'yarn coko-client-build')
  yarnBuildScript = "coko-client-build";

  installPhase = ''
    runHook preInstall

    # Create the main installation directory
    mkdir -p $out/lib/wax-client

    # Copy the built client files
    cp -r _build $out/lib/wax-client/

    # Copy the env.sh script for runtime environment setup
    cp node_modules/@coko/client/scripts/env.sh $out/lib/wax-client/

    # Create a simple launcher script
    mkdir -p $out/bin
    cat > $out/bin/wax-client-unwrapped << 'EOF'
      #!/bin/sh
      # Change to the wax-client directory
      cd "$WAXCLIENT_ROOT"
      # Execute env.sh to set up runtime environment, then serve
      exec sh ./env.sh serve -p 8080 --single ./_build "$@"
    EOF
    chmod +x $out/bin/wax-client-unwrapped

    runHook postInstall
  '';

  postFixup = ''
    # Use wrapProgram to set environment variables and paths
    wrapProgram $out/bin/wax-client-unwrapped \
      --prefix PATH : ${lib.makeBinPath [ nodePackages.serve ]} \
      --set WAXCLIENT_ROOT "$out/lib/wax-client" \

    # Create the final wax-client symlink
    ln -s $out/bin/wax-client-unwrapped $out/bin/wax-client
  '';

  meta = {
    homepage = "https://github.com/Wax-Platform/Wax";
    description = "Wax Platform web client for collaborative document editing";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ themadbit ];
    platforms = lib.platforms.all;
    mainProgram = "wax-client";
  };
})
