{
  lib,
  pkgs,
  fetchFromGitHub,
  buildNpmPackage,
  nix-update-script,
  nodejs_22,
  chromium,
  makeWrapper,
}:

buildNpmPackage (finalAttrs: {
  pname = "pagedjs-cli";
  version = "0-unstable-2026-01-05";

  src = fetchFromGitHub {
    owner = "pagedjs";
    repo = "pagedjs-cli";
    rev = "1fc8c8956d665347a6a105c927be405a3ac462d6";
    hash = "sha256-393Q2B64lIPSYIckPOqVdhhQiHKcUE1jOpsYlFsiJvg=";
  };

  npmDepsHash = "sha256-h3R+L9gROCqvKpzTg9woI0Om1J5Eo4NA1FCXjfnjwdU=";

  # Skip Puppeteer's Chrome download during dependency installation
  env = {
    PUPPETEER_SKIP_DOWNLOAD = true;
  };

  npmInstallFlags = [
    "--ignore-scripts"
  ];

  nativeBuildInputs = [
    nodejs_22
    makeWrapper
  ];

  # Wrap the binary to set Chromium path
  # Launch browser with no sandboxing
  postInstall = ''
    mkdir -p $out/lib/node_modules/pagedjs-cli/docker-userdata

    wrapProgram $out/bin/pagedjs-cli \
      --set PUPPETEER_EXECUTABLE_PATH "${chromium}/bin/chromium" \
      --add-flags "--browserArgs --no-sandbox"
  '';

  passthru.updateScript = nix-update-script { extraArgs = [ "--version=branch" ]; };

  meta = {
    description = "Command line interface for Pagedjs";
    homepage = "https://pagedjs.org";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ themadbit ];
    teams = [ lib.teams.ngi ];
    mainProgram = "pagedjs-cli";
  };
})
