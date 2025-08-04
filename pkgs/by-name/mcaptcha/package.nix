{
  mkYarnPackage,
  fetchYarnDeps,
  fetchFromGitHub,
  rustPlatform,
  lib,
  openssl,
  pkg-config,
  perl,
}:
let
  version = "0.1.0";

  releaseDate = "2024-03-15";

  rootSrc = fetchFromGitHub {
    owner = "mCaptcha";
    repo = "mCaptcha";
    rev = "v${version}";
    hash = "sha256-2900GArHM75IHMfN+bWFbeczKrZK/fG50ImUtiLMft4=";
  };

  frontend =
    let
      src = rootSrc;
    in
    mkYarnPackage {
      pname = "mcaptcha-frontend";
      inherit version src;

      packageJSON = ./frontend-package.json;
      offlineCache = fetchYarnDeps {
        yarnLock = "${src}/yarn.lock";
        hash = "sha256-3HttWhqK1EWYnVR+dkp495jNRwib9qq7WJZzQ+Wl1DY=";
      };

      buildPhase = ''
        runHook preBuild

        export HOME=$(mktemp -d)
        yarn --offline build

        runHook postBuild
      '';

      doCheck = true;
      checkPhase = ''
        runHook preCheck
        CI=true yarn test
        runHook postCheck
      '';

      # Copied from `make frontend` in the mCaptcha Makefile:
      # https://github.com/mCaptcha/mCaptcha/blob/f337ee0643d88723776e1de4e5588dfdb6c0c574/Makefile#L130-L147
      installPhase = ''
        runHook preInstall

        yarn run sass -s \
          compressed templates/main.scss  \
          ./static/cache/bundle/css/main.css
        yarn run sass -s \
          compressed templates/mobile.scss  \
          ./static/cache/bundle/css/mobile.css
        yarn run sass -s \
          compressed templates/widget/main.scss  \
          ./static/cache/bundle/css/widget.css

        patchShebangs deps/vanilla/scripts
        deps/vanilla/scripts/librejs.sh
        deps/vanilla/scripts/cachebust.sh

        mv deps/vanilla/static/cache/bundle $out

        runHook postInstall
      '';

      # Note that "true" disables the dist phase, as this is all handled in
      # installPhase above.
      distPhase = "true";
    };

  openapi =
    let
      src = rootSrc + "/docs/openapi";
    in
    mkYarnPackage {
      pname = "mcaptcha-openapi";
      inherit version src;

      packageJSON = ./openapi-package.json;
      offlineCache = fetchYarnDeps {
        yarnLock = "${src}/yarn.lock";
        hash = "sha256-vsgc/y/3aQOwoWM/WWf3oYNX0RucaXvJdgigb56j+w8=";
      };

      buildPhase = ''
        runHook preBuild

        export HOME=$(mktemp -d)
        yarn --offline build

        runHook postBuild
      '';

      installPhase = ''
        runHook preInstall
        mv deps/mcaptcha/dist $out
        runHook postInstall
      '';

      # Note that "true" disables the dist phase, as this is all handled in
      # installPhase above.
      distPhase = "true";
    };

  cache-bust =
    let
      src = rootSrc + "/utils/cache-bust";
    in
    rustPlatform.buildRustPackage {
      inherit src;
      pname = "cache-bust";
      inherit version;

      cargoHash = "sha256-e18PJFmvUf3droMT26Q0ZCgVFCwG9y/efPFO0SlILW0=";
    };

  mcaptcha =
    let
      src = rootSrc;
    in
    rustPlatform.buildRustPackage {
      pname = "mcaptcha";
      inherit version src;

      cargoLock = {
        # Note: this isn't the lockfile from upstream, it has been patched, see
        # ./deduplicate-pow_sha256-in-lockfile.patch for details.
        lockFile = ./mcaptcha-Cargo.lock;
        outputHashes = {
          "actix-auth-middleware-0.2.0" = "sha256-sLd2Fsa02bXE+CTzTcByTF2PAnzn5YEYGekCmw+AG4E=";
          "actix-web-codegen-4.0.0" = "sha256-2MKgeCa9C5WL0TtvQSTvz2YMBBgzn7tnkFL7c7KJFSs=";
          "argon2-creds-0.2.2" = "sha256-A5xkcVvi+xfdQ0vBdqJgtlIbiNmOz6weSB3ho6kAz+A=";
        };
      };

      patches = [
        # build.rs does some impure stuff with git to inject a commit hash and
        # a compilation date. That isn't nix-compatible, so we remove it, and
        # simulate its effects (see GIT_HASH and COMPILED_DATE below).
        ./no-build-script.patch
      ];

      # Remove the build.rs mentioned in no-build-script.patch above. (This is
      # just less likely to run into future conflicts vs if we put it in the
      # patch file).
      postPatch = ''
        rm build.rs
        cp ${./mcaptcha-Cargo.lock} Cargo.lock
      '';

      # Setting these variables to simulate the behavior of the (impure)
      # build.rs script we've removed.
      GIT_HASH = src.rev;
      COMPILED_DATE = releaseDate;

      preBuild = ''
        ln -s ${openapi} docs/openapi/dist
        ln -s ${frontend} static/cache/bundle
        (cd utils/cache-bust && ${cache-bust}/bin/cache-bust)
      '';

      # Most of the tests are database integration tests
      doCheck = false;

      # Get openssl-sys to use pkg-config
      OPENSSL_NO_VENDOR = 1;

      nativeBuildInputs = [
        pkg-config
        perl
      ];

      buildInputs = [ openssl ];

      meta = {
        url = "https://mcaptcha.org/";
        description = "mCaptcha is proof-of-work based captcha system that is privacy focused and fully automated.";
        license = lib.licenses.agpl3Plus;
        mainProgram = "mcaptcha";
      };
    };
in
# Temporary fix: libmcaptcha crashes when redis doesn't reply to a module listing request with the mcaptcha module as
# the first entry
# Until this is addressed upstream and has found its way into the version of libmcaptcha used in mcaptcha, add our patch
mcaptcha.overrideAttrs (oa: {
  cargoDeps = oa.cargoDeps.overrideAttrs (oa2: {
    buildCommand = oa2.buildCommand + ''
      realdir="$(realpath $out/libmcaptcha-0.2.4)"
      rm "$out/libmcaptcha-0.2.4"
      cp -r --no-preserve=mode "$realdir" "$out/libmcaptcha-0.2.4"

      pushd "$out/libmcaptcha-0.2.4"
      patch -p1 < ${./1001-libmcaptcha-Allow-redis-module-to-not-be-first-in-list.patch}
      popd
    '';
  });
})
