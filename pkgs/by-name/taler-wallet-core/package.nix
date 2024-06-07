{
  lib,
  stdenv,
  buildGoModule,
  fetchFromGitHub,
  fetchgit,
  git,
  jq,
  moreutils,
  nodePackages,
  cacert,
  python3,
  zip,
}: let
  esbuild_0_19_9 = buildGoModule rec {
    pname = "esbuild";
    version = "0.19.9";

    src = fetchFromGitHub {
      owner = "evanw";
      repo = "esbuild";
      rev = "v${version}";
      hash = "sha256-GiQTB/P+7uVGZfUaeM7S/5lGvfHlTl/cFt7XbNfE0qw=";
    };
    vendorHash = "sha256-+BfxCyg0KkDQpHt/wycy/8CTG6YBA/VJvJFhhzUnSiQ=";

    subPackages = ["cmd/esbuild"];

    ldflags = [
      "-s"
      "-w"
    ];

    meta = {
      description = "An extremely fast JavaScript bundler";
      homepage = "https://esbuild.github.io";
      license = lib.licenses.mit;
      mainProgram = "esbuild";
    };
  };
  taler-wallet-core-pnpm-deps = stdenv.mkDerivation rec {
    pname = "taler-wallet-core-pnpm-deps";
    version = "0.11.2";

    src = fetchgit {
      url = "https://git.taler.net/wallet-core.git";
      rev = "v${version}";
      hash = "sha256-GtR87XqmunYubh9EiY3bJIqXiXrT+re3KqWypYK3NCo=";
    };

    nativeBuildInputs = [
      jq
      moreutils
      nodePackages.pnpm
      cacert
    ];

    dontBuild = true;

    installPhase = ''
      runHook preInstall

      export HOME=$(mktemp -d)

      pnpm config set store-dir $out
      pnpm install --frozen-lockfile --ignore-script

      rm -rf $out/v3/tmp
      for f in $(find $out -name "*.json"); do
        sed -i -E -e 's/"checkedAt":[0-9]+,//g' $f
        jq --sort-keys . $f | sponge $f
      done

      runHook postInstall
    '';

    dontFixup = true;

    outputHashAlgo = "sha256";
    outputHashMode = "recursive";
    outputHash =
      {
        aarch64-linux = "sha256-8n/vM4RVyfbYf34i5CtlI/Hj9LGZtCpgYVnOvBZI7x4=";
        x86_64-linux = "sha256-gsWbzFNy/bH+MLisiRms+sjF0fIdbChFbWjbhl8eA+Q=";
      }
      .${stdenv.system}
      or (throw "Unsupported system: ${stdenv.system}");
  };
in
  stdenv.mkDerivation {
    pname = "taler-wallet-core";
    inherit (taler-wallet-core-pnpm-deps) version src;

    nativeBuildInputs = [
      git
      jq
      nodePackages.nodejs
      nodePackages.pnpm
      python3
      zip
    ];

    buildInputs = [nodePackages.nodejs];

    postUnpack = ''
      git init -b master
      git config user.email "root@localhost"
      git config user.name "root"
      git commit --allow-empty -m "Initial commit"
    '';

    postPatch = ''
      patchShebangs packages/*/*.mjs
      substituteInPlace pnpm-lock.yaml \
        --replace-fail "esbuild: 0.12.29" "esbuild: ${esbuild_0_19_9.version}"
    '';

    preConfigure = ''
      ./bootstrap
    '';

    preBuild = ''
      export HOME=$(mktemp -d)

      pnpm config set store-dir ${taler-wallet-core-pnpm-deps}
      pnpm install --offline --frozen-lockfile --ignore-script
      patchShebangs node_modules/{*,.*}
    '';

    env.ESBUILD_BINARY_PATH = lib.getExe esbuild_0_19_9;

    meta = {
      description = "A wallet for GNU Taler written in TypeScript and Anastasis Web UI";
      homepage = "https://git.taler.net/wallet-core.git/";
      license = lib.licenses.gpl3Plus;
      platforms = lib.platforms.linux;
    };
  }
