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
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "wax-server";
  version = "0-unstable-2025-08-14";

  src = fetchFromGitHub {
    owner = "Wax-Platform";
    repo = "Wax";
    rev = "01316b557d201b09b4ce9745c7d7e841d94b8268";
    hash = "sha256-afc15miIzzEBRrzvJaRzSK+IWe4/36+Lvo7IbmNM2CA=";
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

  meta = {
    homepage = "https://github.com/Wax-Platform/Wax";
    description = "Wax Platform web server for collaborative document editing";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ themadbit ];
    team = with lib.teams; [ ngi ];
    platforms = lib.platforms.all;
    mainProgram = "wax-server";
  };
})
