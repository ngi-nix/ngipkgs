{
  lib,
  stdenv,
  fetchgit,
  fetchurl,
  fetchzip,

  meson,
  ninja,
  python3,
  cmake,
  pkg-config,

  libllvm,
  libclang,
  cppzmq,

}:
let
  ghidra-src = fetchurl {
    url = "https://github.com/NationalSecurityAgency/ghidra/archive/Ghidra_11.4.1_build/Ghidra_11.4.1_build.tar.gz";
    sha256 = "sha256-ij+VXwT0opRa/FcacPHCFABSzdIw+6uZYVsd6EgM5PA=";
  };

  ghidra-patches = fetchzip {
    url = "https://codeberg.org/ReOxide/ghidra-wrap/releases/download/v11.4.1/ghidra_11.4.1_patch.zip";
    sha256 = "sha256-DbWaIYMj+edBuEzF1Pw9TyyCKAeT8ade9fot1idtzBA=";
  };
in
stdenv.mkDerivation (finalAttrs: {
  name = "reoxide";
  version = "0.6.1";

  src = fetchgit {
    url = "https://codeberg.org/ReOxide/reoxide.git";
    leaveDotGit = false;
    tag = "v${finalAttrs.version}";
    hash = "sha256-/BhwDkbhA/RjDdE+QxZwSQ8e+o2kGVsxIBFss8g1tHg=";
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
    #!/usr/bin/env python3
    import sys
    if len(sys.argv) > 1 and sys.argv[1] == 'get-vcs':
        print('${finalAttrs.version}')
    else:
        exit(1)
    EOF

    # TODO: figure how to process subprojects manually
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
  };
})
