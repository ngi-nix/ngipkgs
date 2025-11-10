{
  stdenv,
  lib,
  fetchFromGitHub,
  fetchurl,
  autoPatchelfHook,
  gettext,
  gradle_9,
  # Project asks specifically for a Java with languageVersion=23
  # NOTE: jdk23 is EOL and has been deprecated
  jdk25_headless,
  makeWrapper,
  tailwindcss,
  unzip,
  which,
  nix-update-script,
}:
let
  gradle = gradle_9;
  jdk_headless = jdk25_headless;

  slop-src = fetchFromGitHub {
    owner = "MarginaliaSearch";
    repo = "SlopData";
    rev = "3277a0a0fb09cd8e86e6a2e49a7981ebdf66b4df";
    hash = "sha256-JCbTlQt0OiYyY5bJJsu+4NW0AUSqzA7pYv2JZgidfrI=";
  };
in
stdenv.mkDerivation (finalAttrs: {
  pname = "marginalia-search";
  version = "24.10.0-unstable-2025-11-09";

  src = fetchFromGitHub {
    owner = "MarginaliaSearch";
    repo = "MarginaliaSearch";
    rev = "4aa37e16d126e1f0cd9592b53a6554e57a44b3cc";
    hash = "sha256-IDt7A5ZXhu9Un9r72esHTwRyUKiwpvE8LKnzM5ccLeI=";
  };

  patches = [
    # ./2001-Make-data-path-configurable-as-well.patch
    # ./2002-Make-slop-an-in-tree-project.patch
  ];

  postPatch = ''
    patchShebangs run/*.sh code/libraries/native/findliburing.sh

    substituteInPlace code/services-application/search-service/build.gradle \
      --replace-fail "commandLine 'npx', 'tailwindcss'" "commandLine 'tailwindcss'"

    substituteInPlace srcsets.gradle \
      --replace-fail "junit-platform-launcher" "junit-platform-launcher:1.13.4"

    cp -r --no-preserve=mode ${slop-src} third-party/slop
  '';

  strictDeps = true;

  mitmCache =
    (gradle.fetchDeps {
      inherit (finalAttrs) pname;
      pkg = finalAttrs.finalPackage;
      data = ./deps.json;
    }).overrideAttrs
      (oa: {
        nativeBuildInputs = (oa.nativeBuildInputs or [ ]) ++ [
          autoPatchelfHook
          jdk_headless
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
              "https/repo.maven.apache.org/maven2/com/google/protobuf/protoc/3.0.2/protoc-3.0.2-linux-x86_64.exe"
              "https/repo.maven.apache.org/maven2/io/grpc/protoc-gen-grpc-java/1.1.2/protoc-gen-grpc-java-1.1.2-linux-x86_64.exe"
            ]
          )
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
    gettext
    gradle
    makeWrapper
    tailwindcss
    unzip
    which
  ];

  gradleFlags = [
    "-Dorg.gradle.java.home=${jdk_headless}"
  ];

  preConfigure = ''
    export HOME=$TEMP
  '';

  installPhase = ''
    runHook preInstall

    # Unpack & install built files

    tar -xvf code/services-core/single-service-runner/build/distributions/marginalia.tar
    mv marginalia $out
    rm $out/bin/marginalia.bat
    wrapProgram $out/bin/marginalia \
      --set JAVA_HOME '${jdk_headless}'

    mkdir -p run/{model,data}
    cp -r run{/template,}/conf

    # Script runs mkdir -p too late
    mkdir -p $out/share/marginalia

    run/install-noninteractive.sh $out/share/marginalia

    install -Dm644 run/setup.sh $out/share/marginalia/setup.sh

    # Install separately-downloaded files needed before execution
  ''
  + (lib.strings.concatMapStringsSep "\n" (
    download:
    ''
      mkdir -p $out/share/marginalia/${download.dir}
    ''
    + ''
      ln -s ${
        fetchurl {
          inherit (download) name url hash;
        }
      } $out/share/marginalia/${download.dir}/${download.name}
    ''
  ) (import ./external-downloads.nix))
  + ''
    runHook postInstall
  '';

  passthru.updateScript = nix-update-script { extraArgs = [ "--version=branch" ]; };

  meta = {
    description = "Internet search engine for text-oriented websites, indexing the small, old and weird web";
    homepage = "https://marginalia-search.com/";
    license = lib.licenses.agpl3Plus;
    mainProgram = "marginalia";
    maintainers = [ ];
    platforms = lib.platforms.linux;
  };
})
