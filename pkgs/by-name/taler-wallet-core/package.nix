{
  lib,
  stdenv,
  buildGoModule,
  fetchFromGitHub,
  fetchgit,
  git,
  jq,
  nodejs,
  pnpm,
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
in
  stdenv.mkDerivation rec {
    pname = "taler-wallet-core";
    version = "0.11.2";

    src = fetchgit {
      url = "https://git.taler.net/wallet-core.git";
      rev = "v${version}";
      hash = "sha256-GtR87XqmunYubh9EiY3bJIqXiXrT+re3KqWypYK3NCo=";
    };

    pnpmDeps = pnpm.fetchDeps {
      inherit src pname;
      hash = "sha256-RdG/QnZNIvQIMU7ScSFz2OfbctHBr65GWXLPvVaybfQ=";
    };

    nativeBuildInputs = [
      git
      jq
      nodejs
      pnpm.configHook
      python3
      zip
    ];

    buildInputs = [nodejs];

    postUnpack = ''
      git init -b master
      git config user.email "root@localhost"
      git config user.name "root"
      git commit --allow-empty -m "Initial commit"
    '';

    patches = [
      ./taler-python-3.12.patch
    ];

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
