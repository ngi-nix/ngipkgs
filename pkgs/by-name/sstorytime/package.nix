{
  lib,
  buildGoModule,
  fetchFromGitHub,
  postgresql,
  postgresqlTestHook,
  nix-update-script,
}:

buildGoModule (finalAttrs: {
  pname = "sstorytime";
  version = "0.1.2-alpha";

  src = fetchFromGitHub {
    owner = "markburgess";
    repo = "SSTorytime";
    tag = finalAttrs.version;
    hash = "sha256-TFebbpqvxaHeQKduOW/1w4V/o5UD55eIVeu7WVqgFjg=";
  };

  sourceRoot = "${finalAttrs.src.name}/src";

  vendorHash = "sha256-OXE/APm4ypsPsv4V5zvEFHe6LwJhnwnP8Ni88e5tdzU=";

  ldflags = [
    "-s"
    "-w"
  ];

  buildPhase = ''
    runHook preBuild

    make all

    # build necessary tools for the tests
    pushd demo_pocs
      make all
    popd

    runHook postBuild
  '';

  nativeCheckInputs = [
    postgresql
    postgresqlTestHook
  ];

  env = {
    DBHOST = "127.0.0.1";
    PGDATABASE = "sstoryline";
    PGUSER = "sstoryline";
    PGPASSWORD = "sst_1234";
  };

  checkPhase = ''
    runHook preCheck

    pushd ../tests
      make test
    popd

    runHook postCheck
  '';

  postInstall = ''
    mkdir -p $out/{bin,share/config}

    installExecutables () {
      for file in $EXECUTABLES; do
        install -Dm755 "$file" -t $out/bin
      done
    }

    EXECUTABLES="N4L \
    searchN4L \
    removeN4L \
    http_server \
    pathsolve \
    notes \
    graph_report \
    API_EXAMPLE_1 \
    API_EXAMPLE_2 \
    API_EXAMPLE_3 \
    API_EXAMPLE_4"

    installExecutables

    pushd demo_pocs
      EXECUTABLES="postgres_testdb \
      search_coarse_grain_api \
      search_wardley \
      search_coarse_grain \
      search_coarse_grain2 \
      search_coarse_grain_api \
      dotest_entirecone \
      dotest_getnodes \
      definecontext"

      installExecutables
    popd

    cp -R ../SSTconfig $out/share/config
    cp -R ../examples $out/share/
  '';

  passthru.updateScript = nix-update-script { };

  meta = {
    description = "Unified Graph Process For Mapping Knowledge";
    homepage = "https://github.com/markburgess/SSTorytime";
    license = lib.licenses.asl20;
    platforms = lib.platforms.linux;
    teams = with lib.teams; [ ngi ];
    mainProgram = "N4L";
  };
})
