{
  lib,
  python3,
  fetchFromGitea,
  cacert,
  clang,
  meson,
  pkg-config,
  cppzmq,
  libclang,
  libllvm,
  ghidra,
}:
python3.pkgs.buildPythonApplication rec {
  pname = "reoxide";
  version = "0.7.0";
  pyproject = true;

  src = fetchFromGitea {
    domain = "codeberg.org";
    owner = "ReOxide";
    repo = "reoxide";
    tag = "v${version}";
    hash = "sha256-cHJZhYJvCBXRB+V1SP/g1YBzGdwC9drOStVPCwdi6lo=";

    nativeBuildInputs = [
      meson
      cacert
    ];

    postFetch = ''
      pushd "$out"
        for prj in subprojects/*.wrap; do
          meson subprojects download "$(basename "$prj" .wrap)"
          rm -rf subprojects/$(basename "$prj" .wrap)/.git
        done
      popd
    '';
  };

  build-system = [
    clang
    pkg-config
    python3.pkgs.meson
    python3.pkgs.meson-python
    python3.pkgs.ninja
    python3.pkgs.setuptools
  ];

  dependencies = with python3.pkgs; [
    cppzmq
    libclang
    libllvm
    platformdirs
    pyyaml
    pyzmq
  ];

  mesonFlags = [
    (lib.mesonBool "b_ndebug" true)
    (lib.mesonEnable "extract-actions" true)
  ];

  postPatch = ''
    # Replace version.py with a version that returns the package version
    cat > scripts/version.py << 'EOF'
    #! ${python3.interpreter}

    import sys
    if len(sys.argv) > 1 and sys.argv[1] == 'get-vcs':
        print('${version}'.split('-')[0])
    else:
        exit(1)
    EOF

  '';

  postFixup = ''
    # Patch ghidra decompiler path to use reoxide decompile binary
    mkdir -p $out/opt
    cp -R --no-preserve=mode ${ghidra}/lib/ghidra $out/opt
    pushd $out/opt/ghidra/Ghidra/Features/Decompiler/os/linux_x86_64
      mv decompile decompile.orig
      cp $out/lib/python3.13/site-packages/reoxide/data/bin/decompile .
    popd
    chmod +x $out/opt/ghidra/ghidraRun
    chmod +x $out/opt/ghidra/support/launch.sh
    ln -s $out/opt/ghidra/ghidraRun $out/bin/reoxided-ghidra
  '';

  pythonImportsCheck = [
    "reoxide"
  ];

  meta = {
    description = "Plugin System for the Ghidra Decompiler";
    homepage = "https://codeberg.org/ReOxide/reoxide";
    license = lib.licenses.asl20;
    maintainers = with lib.maintainers; [
      themadbit
    ];
    teams = with lib.teams; [ ngi ];
    mainProgram = "reoxide";
    platforms = lib.platforms.linux;
  };
}
