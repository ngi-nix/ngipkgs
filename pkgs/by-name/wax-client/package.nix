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
  nix-update-script,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "wax-client";
  version = "0-unstable-2025-10-07";

  src = fetchFromGitHub {
    owner = "Wax-Platform";
    repo = "Wax";
    rev = "e87966c0b3c629e3ae03ba3423f8cb8c4ce8a6d7";
    hash = "sha256-2gOv6S9TfzAZH5OloNtRo1jJFvfrrP8/i2zNX6hEq2U=";
  };

  sourceRoot = "${finalAttrs.src.name}/packages/client";

  yarnOfflineCache = fetchYarnDeps {
    yarnLock = "${finalAttrs.src}/packages/client/yarn.lock";
    hash = "sha256-yvl8VrAHqPuiDEWO4KB6NKRhRzxkZhD/SvQVGzrX2fU=";
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

  passthru.updateScript = nix-update-script { extraArgs = [ "--version=branch" ]; };

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
