{
  mkSbtDerivation,
  bbb-shared-utils,
}:

mkSbtDerivation {
  pname = "bbb-fsesl-client";
  version = bbb-shared-utils.versionComponent;

  inherit (bbb-shared-utils) src postPatch;

  overrideDepsAttrs = final: prev: {
    preBuild = ''
      cd bbb-fsesl-client
    '';
  };

  depsWarmupCommand = ''
    sbt compile
  '';
  depsArchivalStrategy = "copy";
  depsOptimize = false;
  depsSha256 = "sha256-C0Myb0SC8DWgWcjQyYhthFY9jvH+zG2qm+4dYr6aIVw=";

  strictDeps = true;

  buildPhase = ''
    runHook preBuild

    cd bbb-fsesl-client

    sbt publishLocal

    runHook postBuild
  '';

  installPhase = ''
    runHook preInstall

    mkdir $out
    cp -t $out/ -r $SBT_DEPS/project/.ivy/local/*

    runHook postInstall
  '';

  meta = bbb-shared-utils.meta // {
    description = bbb-shared-utils.meta.description + " (bbb-fsesl-client)";
  };
}
