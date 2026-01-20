{
  lib,
  stdenv,
  fetchFromGitHub,
  fetchYarnDeps,
  yarnConfigHook,
  yarnInstallHook,
  nodejs,
  makeWrapper,
  openjdk11,
  git,
  python3,
  gnumake,
  gcc,
  imagemagick,
  potrace,
  yarn,
  node-pre-gyp,
  nix-update-script,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "wax-server";
  version = "0-unstable-2025-10-07";

  src = fetchFromGitHub {
    owner = "Wax-Platform";
    repo = "Wax";
    rev = "e87966c0b3c629e3ae03ba3423f8cb8c4ce8a6d7";
    hash = "sha256-2gOv6S9TfzAZH5OloNtRo1jJFvfrrP8/i2zNX6hEq2U=";
  };

  sourceRoot = "${finalAttrs.src.name}/packages/server";

  yarnOfflineCache = fetchYarnDeps {
    yarnLock = "${finalAttrs.src}/packages/server/yarn.lock";
    hash = "sha256-k7yj54kvu6/goB+PK6uVLABPbf1W+eXwYCl82Yi1qlc=";
  };

  nativeBuildInputs = [
    yarnConfigHook
    yarnInstallHook
    nodejs
    makeWrapper
    openjdk11
    git
    python3
    gnumake
    gcc
    node-pre-gyp
  ];

  buildInputs = [
    imagemagick
    potrace
  ];

  preBuild = ''
    export JAVA_HOME=${openjdk11}/lib/openjdk

    # Building bcrypt with node-gyp requires node headers
    # See https://nixos.org/manual/nixpkgs/unstable/#javascript-yarn2nix-pitfalls
    export npm_config_nodedir=${nodejs}
  '';

  postInstall = ''
    cd $out/lib/node_modules/server

    ${node-pre-gyp}/bin/node-pre-gyp install --fallback-to-build --directory node_modules/bcrypt

    makeWrapper ${yarn}/bin/yarn $out/bin/wax-server \
      --add-flags "coko-server" \
      --add-flags "start" \
      --chdir "$out/lib/node_modules/server" \
      --set JAVA_HOME ${openjdk11}/lib/openjdk \
      --prefix PATH : ${
        lib.makeBinPath [
          imagemagick
          potrace
        ]
      }
  '';

  passthru.updateScript = nix-update-script { extraArgs = [ "--version=branch" ]; };

  meta = {
    homepage = "https://github.com/Wax-Platform/Wax";
    description = "Wax Platform web server for collaborative document editing";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ themadbit ];
    teams = with lib.teams; [ ngi ];
    platforms = lib.platforms.all;
    mainProgram = "wax-server";
  };
})
