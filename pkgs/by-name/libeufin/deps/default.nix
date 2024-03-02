# There are lots of manual interaction here. Once https://github.com/NixOS/nixpkgs/pull/272380
# lands, we could look into using gradleHook for this package.
{
  pname,
  version,
  src,
  patches,
  gradle,
  fetchurl,
  stdenv,
  fetchgit,
  writeText,
  symlinkJoin,
  perl,
  callPackage,
}: let
  nameprefix = "${pname}-${version}";
  # Pre-download deps into derivation
  deps = stdenv.mkDerivation {
    name = "${nameprefix}-auto-deps";
    inherit patches src version;

    nativeBuildInputs = [gradle perl];
    buildPhase = ''
      export GRADLE_USER_HOME=$(mktemp -d)
      gradle --no-daemon assemble
    '';
    # Mavenize paths: each part of the namespace is a folder.
    installPhase = ''
      find $GRADLE_USER_HOME/caches/modules-2 -type f -regex '.*\.\(jar\|pom\)' \
        | perl -pe 's#(.*/([^/]+)/([^/]+)/([^/]+)/[0-9a-f]{30,40}/([^/\s]+))$# ($x = $2) =~ tr|\.|/|; "install -Dm444 $1 \$out/$x/$3/$4/$5" #e' \
        | sh

      # Work around naming issues. Remove "-gradleXX" from filename.
      mv $out/org/jetbrains/kotlin/kotlin-gradle-plugin/1.9.20/kotlin-gradle-plugin-1.9.20{-gradle81,}.jar
      mv $out/org/jetbrains/kotlin/kotlin-serialization/1.9.20/kotlin-serialization-1.9.20{-gradle81,}.jar
    '';
    outputHashMode = "recursive";
    outputHash = "sha256-0zHxaLGuRxvswtcd5LQpDS56cizygnT92KteEO8UWR4=";
    outputHashAlgo = "sha256";
  };
  # For dependencies that are still missing, we fetch them individually from Maven
  artifactsMeta = import ./artifacts.nix;
  fetchArtifact = x:
    callPackage ./fetch-maven-artifact.nix {
      inherit (x) url sha256;
      inherit nameprefix;
    };
in
  # Merge the offlibe Maven repo folders into a unique derivation
  symlinkJoin {
    name = "${nameprefix}-offline-deps";
    paths = [deps] ++ (map fetchArtifact artifactsMeta);
  }
