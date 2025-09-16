{
  mkSbtDerivation,
  bbb-shared-utils,
}:

mkSbtDerivation {
  pname = "bbb-common-message";
  version = bbb-shared-utils.versionComponent;

  inherit (bbb-shared-utils) src;

  overrideDepsAttrs = final: prev: {
    preBuild = ''
      cd bbb-common-message
    '';
  };

  depsWarmupCommand = ''
    sbt compile
  '';
  depsArchivalStrategy = "copy";
  depsOptimize = false;
  depsSha256 = "sha256-SwtcQrEicIggDBAL51xeHnnPg21Z4wlq8ZyatcFe320=";

  inherit (bbb-shared-utils) postPatch;

  strictDeps = true;

  buildPhase = ''
    runHook preBuild

    cd bbb-common-message

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
    description = bbb-shared-utils.meta.description + " (bbb-common-message)";
  };
}
