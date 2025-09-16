{
  mkSbtDerivation,
  bbb-src,
}:

mkSbtDerivation {
  pname = "bbb-common-message";
  version = "3.0.10-bigbluebutton";

  src = bbb-src;

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

  postPatch = ''
    patchShebangs build/setup-inside-docker.sh build/packages-template

    # This is for setting up cache persistency in docker across runs. We don't want this.
    substituteInPlace build/setup-inside-docker.sh \
      --replace-fail 'ln -s "''${SOURCE}/cache/''${dir}" "/root/''${dir}"' '#ln -s "''${SOURCE}/cache/''${dir}" "/root/''${dir}"' \
      --replace-fail 'CACHE_DIR="/root/"' 'CACHE_DIR="''${SOURCE}/cache/"'
  '';

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
}
