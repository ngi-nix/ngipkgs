{
  lib,
  maven,
  fetchFromGitHub,
  jdk_headless,
  makeWrapper,
}:
maven.buildMavenPackage rec {
  pname = "openfire";
  version = "4.9.0";

  src = fetchFromGitHub {
    owner = "igniterealtime";
    repo = "Openfire";
    rev = "v${version}";
    hash = "sha256-exZDH3wROQyw8WIQU1WZB3QoXseiSHueo3hiQrjQZGM=";
  };

  mvnJdk = jdk_headless;
  mvnHash = "sha256-PovHnAR10IxDTyoXCH4LCWZzIv6cNMl9JI0B4stDBo8=";

  # some deps require internet for tests
  mvnParameters = "-Dmaven.test.skip";

  nativeBuildInputs = [ makeWrapper ];

  installPhase = ''
    runHook preInstall

    mkdir -p $out/{bin,opt}

    cp -R ./distribution/target/distribution-base/* $out/opt
    ln -s $out/opt/lib $out/lib

    for file in openfire.sh openfirectl; do
      wrapProgram $out/opt/bin/$file \
        --set JAVA_HOME ${jdk_headless.home}

      install -Dm555 $out/opt/bin/$file -t $out/bin
    done

    # Used to determine if the Openfire state directory needs updating
    echo ${version} > $out/opt/version

    runHook postInstall
  '';

  meta = {
    description = "An XMPP server licensed under the Open Source Apache License";
    homepage = "https://github.com/igniterealtime/Openfire";
    license = lib.licenses.asl20;
    maintainers = with lib.maintainers; [ ];
    mainProgram = "openfire";
    platforms = lib.platforms.all;
  };
}
