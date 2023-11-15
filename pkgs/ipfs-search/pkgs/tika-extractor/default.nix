{
  fetchFromGitHub,
  jdk11_headless,
  makeWrapper,
  maven,
  mvn2nix,
  stdenv,
}: let
  pname = "tika-extractor";
  version = "1.1";
  mavenRepository = mvn2nix.buildMavenRepositoryFromLockFile {file = ./mvn2nix-lock.json;};
in
  stdenv.mkDerivation {
    inherit pname version;

    src = fetchFromGitHub {
      owner = "ipfs-search";
      repo = "tika-extractor";
      rev = "v${version}";
      hash = "sha256-nXCGTHcz5rrVHFqAcuNxDTDLSMX9WcVQducCfzGjfnk=";
    };

    nativeBuildInputs = [jdk11_headless maven makeWrapper];

    buildPhase = ''
      mvn package --offline -Dmaven.repo.local=${mavenRepository} -Dquarkus.package.type=uber-jar
    '';

    installPhase = ''
      mkdir -p $out/bin
      ln -s ${mavenRepository} $out/lib
      cp target/${pname}-${version}-runner.jar $out/
      makeWrapper ${jdk11_headless}/bin/java $out/bin/${pname} \
            --add-flags "-jar $out/${pname}-${version}-runner.jar"
    '';
  }
