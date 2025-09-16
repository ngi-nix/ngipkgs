{
  lib,
  fetchFromGitea,
  clangStdenv,

  meson,
  clang,
  ninja,
  reoxide,
}:

clangStdenv.mkDerivation (finalAttrs: {
  pname = "reoxide-plugin-simple";
  version = "0-unstable-2025-09-12";

  # use latest dev branch commit
  src = fetchFromGitea {
    domain = "codeberg.org";
    owner = "ReOxide";
    repo = "plugin-template";
    rev = "ef4856f1a4a146b6b07e5969ad60289f9ce47abd";
    hash = "sha256-/kROJRarla8uV3jRMgyuNVJ5wxC8OfliwHG5iRl6yiE=";
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
