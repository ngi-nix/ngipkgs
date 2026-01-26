{
  lib,
  fetchFromGitea,
  clangStdenv,

  meson,
  clang,
  ninja,
  reoxide,

  nix-update-script,
}:

clangStdenv.mkDerivation (finalAttrs: {
  pname = "reoxide-plugin-simple";
  version = "0-unstable-2026-01-15";

  # use latest dev branch commit
  src = fetchFromGitea {
    domain = "codeberg.org";
    owner = "ReOxide";
    repo = "plugin-template";
    rev = "f473cc6d789fcbae35124e0a220da76eafcc678c";
    hash = "sha256-AA/rinhKW6IuYxsw5jiHKThXRWiZ/LBckwnNb/D906I=";
  };

  nativeBuildInputs = [
    meson
    clang
    ninja
    reoxide
  ];

  env = {
    CC = "${clangStdenv.cc}/bin/clang";
    CXX = "${clangStdenv.cc}/bin/clang++";
  };

  mesonBuildType = "release";

  preConfigure = ''
    mkdir -p .config/reoxide
    touch .config/reoxide/reoxide.toml
    export HOME=$PWD

    meson setup --buildtype=release build
  '';

  postInstall = ''
    mkdir -p $out/lib
    cp simple/libsimple.so $out/lib/
  '';

  passthru.updateScript = nix-update-script { extraArgs = [ "--version=branch" ]; };

  meta = {
    description = "Simple plugin template for reoxide";
    homepage = "https://codeberg.org/ReOxide/reoxide";
    license = lib.licenses.asl20;
    maintainers = with lib.maintainers; [
      themadbit
    ];
    teams = with lib.teams; [ ngi ];
    platforms = lib.platforms.linux;
  };
})
