{
  lib,
  stdenv,
  fetchFromGitea,
  cacert,

  meson,
  ninja,
  python3,
  cmake,
  pkg-config,

  libllvm,
  libclang,
  cppzmq,
}:
stdenv.mkDerivation (finalAttrs: {
  name = "reoxide";
  version = "0.6.1";

  src = fetchFromGitea {
    domain = "codeberg.org";
    owner = "ReOxide";
    repo = "reoxide";
    rev = "0ba38caa8656aaf109f674c868bff708a7288bb0";
    hash = "sha256-Pnqr4SuupGk0Fa9d5eJ/zWeJiE9gMxBeHvI2cZV60ew=";
    nativeBuildInputs = [
      meson
      cacert
    ];
    postFetch = ''
      (
        cd "$out"
        for prj in subprojects/*.wrap; do
          meson subprojects download "$(basename "$prj" .wrap)"
          rm -rf subprojects/$(basename "$prj" .wrap)/.git
        done
      )
    '';
  };

  nativeBuildInputs = [
    meson
    ninja
    python3
    cmake
    pkg-config
  ];

  buildInputs = [
    cppzmq
    libllvm
    libclang
  ];

  mesonFlags = [
    "-Db_ndebug=true"
    "-Dextract-actions=enabled"
  ];

  postPatch = ''
    # Replace version.py with a version that returns the package version
    cat > scripts/version.py << 'EOF'
    #! ${python3.interpreter}

    import sys
    if len(sys.argv) > 1 and sys.argv[1] == 'get-vcs':
        print('${finalAttrs.version}')
    else:
        exit(1)
    EOF
  '';

  meta = {
    description = "Ghidra plugin system";
    homepage = "https://reoxide.eu";
    license = with lib.licenses; [ asl20 ];
    maintainers = with lib.maintainers; [
      themadbit
    ];
    teams = with lib.teams; [ ngi ];
    mainProgram = "reoxide";
    platforms = lib.platforms.linux;
  };
})
