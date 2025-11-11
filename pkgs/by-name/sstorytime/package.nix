{
  lib,
  buildGoModule,
  fetchFromGitHub,
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

    runHook postBuild
  '';

  postInstall = ''
    mkdir -p $out/{bin,share/config}

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

    for file in $EXECUTABLES; do
      install -Dm755 "$file" -t $out/bin
    done

    cp -R ../SSTconfig $out/share/config
    cp -R ../examples $out/share/
  '';

  # TODO:
  doCheck = false;

  meta = {
    description = "Unified Graph Process For Mapping Knowledge";
    homepage = "https://github.com/markburgess/SSTorytime";
    license = lib.licenses.asl20;
    platforms = lib.platforms.linux;
    teams = with lib.teams; [ ngi ];
    mainProgram = "N4L";
  };
})
