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
  version = "0-unstable-2024-05-31";

  src = fetchFromGitHub {
    owner = "pagedjs";
    repo = "pagedjs-cli";
    rev = "d682e19ee5d14bfe07ad1726540e2423ede75a05";
    hash = "sha256-7DXfBMi6OPNUT1XM5Gtsbk8xK4rz5xmDbJAPulrVTmE=";
  };

  npmDepsHash = "sha256-QX7TkGQ47UunRjsRHn5muE1a6X84GZyHdCEa+blx9Ik=";

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
