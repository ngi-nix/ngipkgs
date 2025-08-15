{
  lib,
  stdenv,
  fetchFromGitHub,
  fetchYarnDeps,
  yarnConfigHook,
  yarnInstallHook,
  nodejs,
  makeWrapper,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "wax-cli";
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
    yarnInstallHook
    nodejs
    makeWrapper
  ];

  # Skip build phase since dependencies install the binary
  dontBuild = true;

  installPhase = ''
    runHook preInstall

    # Install the node_modules and source
    mkdir -p $out/lib/wax-cli
    cp -r node_modules $out/lib/wax-cli/
    cp -r * $out/lib/wax-cli/

    # Create wrapper for the CLI binary
    mkdir -p $out/bin
    makeWrapper ${nodejs}/bin/node $out/bin/wax-cli \
      --add-flags "$out/lib/wax-cli/node_modules/.bin/coko-client-dev-js" \
      --set NODE_PATH "$out/lib/wax-cli/node_modules" \
      --set NODE_ENV "development"

    runHook postInstall
  '';

  meta = {
    homepage = "https://github.com/Wax-Platform/Wax";
    description = "Wax Platform CLI client development tool";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ themadbit ];
    platforms = lib.platforms.all;
  };
})
