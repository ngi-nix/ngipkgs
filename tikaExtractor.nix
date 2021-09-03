{ lib, stdenv, buildMavenRepositoryFromLockFile
, makeWrapper, maven, jdk11_headless
, nix-gitignore
}:


let
  mavenRepository = buildMavenRepositoryFromLockFile { file = ./mvn2nix-lock.json; };
in stdenv.mkDerivation rec {
  pname = "tika-extractor";
  version = "1.1";
  name = "${pname}-${version}";
  src = fetchGit{
    url =https://github.com/ipfs-search/tika-extractor;
    ref ="main";
    rev= "e629c4a6362916001deb430584ddc3fdc8a4bf6a";
      };

  nativeBuildInputs = [ jdk11_headless maven makeWrapper ];
  buildPhase = ''
    echo "Building with maven repository ${mavenRepository}"
    mvn package --offline -Dmaven.repo.local=${mavenRepository} -Dquarkus.package.type=uber-jar
  '';

  installPhase = ''
    # create the bin directory
    mkdir -p $out/bin

    # create a symbolic link for the lib directory
    ln -s ${mavenRepository} $out/lib

    # copy out the JAR
    ls -l
    # Maven already setup the classpath to use m2 repository layout
    # with the prefix of lib/
    cp target/${name}-runner.jar $out/

    # create a wrapper that will automatically set the classpath
    # this should be the paths from the dependency derivation
    makeWrapper ${jdk11_headless}/bin/java $out/bin/${pname} \
          --add-flags "-jar $out/${name}-runner.jar"
  '';
}
