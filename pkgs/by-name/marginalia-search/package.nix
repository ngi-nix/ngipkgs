{
  stdenv,
  lib,
  fetchFromGitHub,
  fetchurl,
  autoPatchelfHook,
  gradle,
  jdk,
  jre_headless,
  makeWrapper,
  unzip,
}:
stdenv.mkDerivation (finalAttrs: {
  pname = "marginalia-search";
  version = "24.01.2-unstable-2024-08-09";

  src = fetchFromGitHub {
    owner = "MarginaliaSearch";
    repo = "MarginaliaSearch";
    rev = "2f38c95886a81729c2fa503f2b46d3d155a46fed";
    hash = "sha256-wvLkEewu+BO8W3yHiPD/MloFYwmCRhdHz7RHQCLg1sU=";
  };

  postPatch = ''
    patchShebangs run/*.sh

    # gunzip complains about "Too many levels of symbolic links" when trying to unpack symlink
    # Just tell it to try anyway, it works fine
    substituteInPlace run/setup.sh \
      --replace-fail 'gunzip data/suggestions.txt.gz' 'gunzip -fk data/suggestions.txt.gz'
  '';

  strictDeps = true;

  mitmCache =
    (gradle.fetchDeps {
      inherit (finalAttrs) pname;
      data = ./deps.json;
    })
    .overrideAttrs (oa: {
      nativeBuildInputs =
        (oa.nativeBuildInputs or [])
        ++ [
          autoPatchelfHook
          jdk
        ];
      dontAutoPatchelf = true;
      buildCommand =
        oa.buildCommand
        # Patchelf downloaded binaries
        + (lib.strings.concatMapStringsSep "\n"
          (path: ''
            target="$(realpath '${path}')"
            rm '${path}'
            cp --no-preserve=mode "$target" '${path}'
            chmod +x '${path}'
            autoPatchelf '${path}'
          '')
          [
            "https/repo1.maven.org/maven2/com/google/protobuf/protoc/3.0.2/protoc-3.0.2-linux-x86_64.exe"
            "https/repo1.maven.org/maven2/io/grpc/protoc-gen-grpc-java/1.1.2/protoc-gen-grpc-java-1.1.2-linux-x86_64.exe"
          ])
        # Unpack, patchelf & repack embedded dart-sass
        + ''
          path='https/plugins.gradle.org/m2/de/larsgrefer/sass/sass-embedded-bundled/3.2.0/sass-embedded-bundled-3.2.0.jar'
          target="$(realpath "$path")"
          rm "$path"

          pushd "$(mktemp -d)"
          jar xvf "$target"

          pushd de/larsgrefer/sass/embedded/bundled
          gunzip -ck dart-sass-linux-x64.tar.gz | tar -xvf-
          rm dart-sass-linux-x64.tar.gz

          autoPatchelf dart-sass/src/dart

          tar -cvf- dart-sass | gzip -9c > dart-sass-linux-x64.tar.gz
          rm -r dart-sass
          popd

          jar -cf "$out"/"$path" *
          popd
        '';
    });

  nativeBuildInputs = [
    gradle
    makeWrapper
    unzip
  ];

  configurePhase =
    ''
      runHook preConfigure

      # Symlink external downloads
    ''
    + (lib.strings.concatMapStringsSep "\n" (download:
      ''
        mkdir -p run/${download.dir}
      ''
      + ''
        ln -s ${fetchurl {
          inherit (download) name url hash;
        }} run/${download.dir}/${download.name}
      '') (import ./external-downloads.nix))
    + ''

      # Unpack downloads as needed, check if we're missing anything
      ./run/setup.sh

      runHook postConfigure
    '';

  installPhase = ''
    runHook preInstall

    # Unpack & install built files

    tar -xvf code/services-core/single-service-runner/build/distributions/marginalia.tar
    mv marginalia $out
    rm $out/bin/marginalia.bat
    wrapProgram $out/bin/marginalia \
      --set JAVA_HOME '${jre_headless}'

    # Mostly mirroring what run/install.sh does next

    pushd run

    for dir in model data conf conf/properties env; do
      mkdir -p $out/share/marginalia/$dir
      # Edit: Also copy links, so all the downloads get copied & stay live
      find $dir -maxdepth 1 \( -type f -o -type l \) -exec cp -Pv {} $out/share/marginalia/$dir \;
    done

    echo "control.hideMarginaliaApp=true" > $out/share/marginalia/conf/properties/control-service.properties
    # (leading with a blank newline is important, as we cannot trust that the source file ends with a new-line)
    cat >>$out/share/marginalia/conf/properties/system.properties <<EOF

    # Override zookeeper hosts for non-docker install here:
    zookeeper-hosts=localhost:2181

    # Override the storage root for non-docker install here:
    storage.root=$out/share/marginalia/index-1
    EOF

    cp prometheus.yml $out/share/marginalia

    mkdir -p $out/share/marginalia/{logs,db,index-1/{work,index,backup,storage,uploads}}
    cp install/mariadb.env.template $out/share/marginalia/env/mariadb.env.template
    cp install/db.properties.template $out/share/marginalia/env/db.properties.template
    cp install/docker-compose-scaffold.yml.template $out/share/marginalia/docker-compose.yml.template

    cat <<EOF > $out/share/marginalia/README
    Quick note about running Marginalia Search in a non-docker environment.

    Beware that this installation mode is more of a proof-of-concept and demonstration that the
    system is not unhealthily dependent on docker, than a production-ready setup, and is not
    recommended for production use!  The container setup is much more robust and easier to manage.

    Note: This script only sets up an install directory, and does not build the system.
    You will need to build the system with "gradlew assemble" before you can run it.

    Each service is spawned by the same launcher.  After building the project with
    "gradlew assemble", the launcher is put in "code/services-core/single-service-runner/build/distributions/marginalia.tar".
    This needs to be extracted!

    Note: The template sets up a sample (in-docker) setup for mariadb and zookeeper.  These can also be run outside
    of docker, but you will need to update the db.properties file and "zookeeper-hosts" in the system.properties
    file to point to the correct locations/addresses.

    Running:

    To launch a process you need to unpack it, and then run the launcher with the
    appropriate arguments.  For example:

    WMSA_HOME=/path/to/install/dir marginalia control:1 127.0.0.1:7000:7001 127.0.0.2

    This command will start the control partition 1 on ports 7000 (HTTP) and 7001 (GRPC),
    bound to 127.0.0.1, and it will announce its presence to the local zookeeper
    instance on 127.0.0.2.

    A working setup needs at all the services

    * control [ http port is the control GUI ]
    * query [ http port is the query GUI ]
    * index [ http port is internal ]
    * executor [ http port is internal ]

    Since you will need to manage ports yourself, you must assign distinct ports-pairs to each service.

    * An index and executor services should exist on the same partition e.g. index:1 and executor:1. The partition
    number is the last digit of the service name, and should be positive.  You can have multiple pairs of index
    and executor partitions, but the pair should run on the same physical machine with the same install directory.

    * The query service can use any partition number.

    * The control service should be on partition 1.

    EOF

    popd

    runHook postInstall
  '';
})
