{
  lib,
  stdenv,
  buildGoModule,
  fetchFromGitHub,
  fetchgit,
  git,
  jq,
  nodejs,
  python3,
  zip,
  pnpm,
  removeReferencesTo,
  srcOnly,
}: let
  nodePackages = nodejs.pkgs;
  nodeSources = srcOnly nodejs;
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

    nativeBuildInputs = [
      git
      jq
      nodePackages.nodejs
      pnpm.configHook
      python3
      zip
    ];

    pnpmDeps = pnpm.fetchDeps {
      inherit pname version src;
      hash = "sha256-RdG/QnZNIvQIMU7ScSFz2OfbctHBr65GWXLPvVaybfQ=";
    };

    buildInputs = [nodePackages.nodejs];

    # Use a fake git?
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

    # After the pnpm configure, we need to build the binaries of all instances
    # of better-sqlite3. It has a native part that it wants to build using a
    # script which is disallowed.
    # Adapted from mkYarnModules.
    preBuild = ''
      for f in $(find -path '*/node_modules/better-sqlite3' -type d); do
        (cd "$f" && (
        npm run build-release --offline --nodedir="${nodeSources}"
        find build -type f -exec \
          ${removeReferencesTo}/bin/remove-references-to \
          -t "${nodeSources}" {} \;
        ))
      done
    '';

    env.ESBUILD_BINARY_PATH = lib.getExe esbuild_0_19_9;

    meta = {
      description = "A wallet for GNU Taler written in TypeScript and Anastasis Web UI";
      homepage = "https://git.taler.net/wallet-core.git/";
      license = lib.licenses.gpl3Plus;
      platforms = lib.platforms.linux;
    };
  }
