{
  lib,
  fetchFromGitea,
  clangStdenv,

  meson,
  clang,
  ninja,
  reoxide,

  libllvm,
  libclang,
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

    clangStdenv.cc
  ];

  buildInputs = [
    libllvm
    libclang
    ninja
  ];

  env = {
    CC = "${clangStdenv.cc}/bin/clang";
    CXX = "${clangStdenv.cc}/bin/clang++";
  };

  mesonFlags = [
    "-Db_ndebug=true"
  ];

  configurePhase = ''
    runHook preConfigure

    mkdir -p .config/reoxide
    touch .config/reoxide/reoxide.toml
    export HOME=$PWD

    meson setup --buildtype=release $mesonFlags build

    runHook postConfigure
  '';

  buildPhase = ''
    runHook preBuild

    ninja -C build

    runHook postBuild
  '';

  installPhase = ''
    runHook preInstall

    mkdir -p $out/lib
    cp build/simple/libsimple.so $out/lib/

    runHook postInstall
  '';

  meta = with lib; {
    description = "Simple plugin template for reoxide";
    homepage = "https://codeberg.org/ReOxide/reoxide";
    license = licenses.asl20;
    maintainers = with maintainers; [
      themadbit
    ];
    teams = with teams; [ ngi ];
    platforms = platforms.linux;
  };
})
