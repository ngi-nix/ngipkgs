{
  lib,
  callPackage,
  stdenv,
  fetchgit,
  makeWrapper,
  python3,
  jdk17_headless,
  gradle-packages,
  writeText,
}: let
  pname = "libeufin";
  version = "0.11.2";
  src = fetchgit {
    url = "https://git.taler.net/libeufin.git/";
    rev = "v${version}";
    hash = "sha256-7w5G8F/XWsWJwkpQQ8GqDA9u6HLV+X9N2RJHn+yXihs=";
    fetchSubmodules = true;
    leaveDotGit = true; # Required for correct submodule fetching
    # Delete .git folder for reproducibility (otherwise, the hash changes unexpectedly after fetching submodules)
    # Save the HEAD short commit hash in a file so it can be retrieved later for versioning.
    postFetch = ''
      (
        cd $out
        git rev-parse --short HEAD > ./common/src/main/resources/HEAD.txt
        rm -rf .git
      )
    '';
  };
  patches = [
    ../taler-wallet-core/taler-python-3.12.patch
    # The .git folder had to be deleted. Read hash from file instead of using the git command.
    ./read-HEAD-hash-from-file.patch
    # Gradle projects provide a .module metadata file as artifact. This artifact is used by gradle
    # to download dependencies to the cache when needed, but do not provide the jar for the
    # offline installation for our build phase. Since we make an offline Maven repo, we have to
    # substitute the gradle deps for their maven counterpart to retrieve the .jar artifacts.
    ./use-maven-deps.patch
  ];

  gradle = callPackage gradle-packages.gradle_8 {java = jdk;};

  # Pre-download deps into a derivation
  deps = callPackage ./deps {inherit gradle patches pname src version;};

  # init.gradle points to the offline maven repository created in the deps derivation
  gradleInit = writeText "init.gradle" (
    builtins.replaceStrings
    ["__DEPS_PATH__"]
    ["${deps}"]
    (builtins.readFile ./init.gradle.template)
  );

  jdk = jdk17_headless;
in
  stdenv.mkDerivation {
    inherit patches pname src version;

    preConfigure = ''
      cp build-system/taler-build-scripts/configure ./configure
    '';

    # Tell gradle to use the offline Maven repository
    buildPhase = ''
      gradle bank:installShadowDist nexus:installShadowDist --offline --no-daemon --init-script ${gradleInit}
    '';

    installPhase = ''
      make install-nobuild

      # wrap commands to provide JAVA_HOME
      for name in libeufin-bank libeufin-dbconfig libeufin-nexus; do
        wrapProgram $out/bin/$name --set JAVA_HOME "${jdk}"
      done
    '';

    nativeBuildInputs = [
      makeWrapper
      python3
      jdk
      gradle
    ];

    # Tests need a database to run.
    doCheck = false;

    meta = {
      homepage = "https://git.taler.net/libeufin.git/";
      description = "Integration and sandbox testing for FinTech APIs and data formats.";
      license = lib.licenses.agpl3Plus;
    };
  }
