{
  mkYarnPackage,
  fetchYarnDeps,
  fetchFromGitHub,
  rustPlatform,
  lib,
  openssl,
  pkg-config,
  perl,
  nixosTests,
}: let
  rootSrc = fetchFromGitHub {
    owner = "mCaptcha";
    repo = "mCaptcha";
    rev = "f337ee0643d88723776e1de4e5588dfdb6c0c574";
    sha256 = "sha256-UP7V2TfbW+KJpNAQLxQIcRsT9ZWYGVkS13XxMbHEH2I=";
  };

  releaseDate = "2023-07-04";

  frontend = let
    src = rootSrc;
  in
    mkYarnPackage {
      pname = "mcaptcha-frontend";
      version = "unstable-${releaseDate}";
      inherit src;

      packageJSON = ./frontend-package.json;
      offlineCache = fetchYarnDeps {
        yarnLock = "${src}/yarn.lock";
        sha256 = "sha256-GyWjQdFJ+hEuR4PebhYzFwiuyMyamRY5GPaJ7rK9Rsc=";
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

  openapi = let
    src = rootSrc + "/docs/openapi";
  in
    mkYarnPackage {
      pname = "mcaptcha-openapi";
      version = "unstable-${releaseDate}";
      inherit src;

      packageJSON = ./openapi-package.json;
      offlineCache = fetchYarnDeps {
        yarnLock = "${src}/yarn.lock";
        sha256 = "sha256-mdd5AwO4WO/RoR/ycR+miJvRXgu1K6WXvMZtyyV/0Tc=";
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

  cache-bust = let
    src = rootSrc + "/utils/cache-bust";
  in
    rustPlatform.buildRustPackage {
      inherit src;
      pname = "cache-bust";
      version = "unstable-${releaseDate}";

      cargoLock = {
        lockFile = ./mcaptcha-cache-bust-Cargo.lock;
        outputHashes = {
          "cache-buster-0.2.0" = "sha256-FT+GV2c+jZyVyC2pEtDm52Aurbf6tOZeBqzHq3NZptw=";
        };
      };
    };

  mcaptcha = let
    src = rootSrc;
  in
    rustPlatform.buildRustPackage {
      inherit src;
      pname = "mcaptcha";
      version = "unstable-${releaseDate}";

      cargoLock = {
        # Note: this isn't the lockfile from upstream, it has been patched, see
        # ./deduplicate-pow_sha256-in-lockfile.patch for details.
        lockFile = ./mcaptcha-Cargo.lock;
        outputHashes = {
          "actix-auth-middleware-0.2.0" = "sha256-sLd2Fsa02bXE+CTzTcByTF2PAnzn5YEYGekCmw+AG4E=";
          "actix-web-codegen-4.0.0" = "sha256-2MKgeCa9C5WL0TtvQSTvz2YMBBgzn7tnkFL7c7KJFSs=";
          "argon2-creds-0.2.2" = "sha256-A5xkcVvi+xfdQ0vBdqJgtlIbiNmOz6weSB3ho6kAz+A=";
          "cache-buster-0.2.0" = "sha256-FT+GV2c+jZyVyC2pEtDm52Aurbf6tOZeBqzHq3NZptw=";
          "libmcaptcha-0.2.3" = "sha256-oedAXrasZ3YAj6PiscdasAQ0RlG9YcFAuFRtxicmkhY=";
          "pow_sha256-0.3.1" = "sha256-gprbSYL0tjKQlQe/lJwFZM0avSQT92nAwUnr61t0X0g=";
        };
      };

      patches = [
        # https://github.com/mCaptcha/mCaptcha/issues/105
        ./support-for-setting-cookie-secret-with-env-var.patch
        # build.rs does some impure stuff with git to inject a commit hash and
        # a compilation date. That isn't nix-compatible, so we remove it, and
        # simulate its effects (see GIT_HASH and COMPILED_DATE below).
        ./no-build-script.patch
        # This is blocked on https://github.com/mCaptcha/libmcaptcha/pull/13.
        # Once that PR is merged, we can re-lock dependencies in mCaptcha, and
        # the duplicate pow_sha256 will go away.
        ./deduplicate-pow_sha256-in-lockfile.patch
      ];

      # Remove the build.rs mentioned in no-build-script.patch above. (This is
      # just less likely to run into future conflicts vs if we put it in the
      # patch file).
      postPatch = ''
        rm build.rs
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

      nativeBuildInputs = [pkg-config perl];

      buildInputs = [openssl];

      meta = {
        url = "https://mcaptcha.org/";
        description = "mCaptcha is proof-of-work based captcha system that is privacy focused and fully automated.";
        license = lib.licenses.agpl3Plus;
        mainProgram = "mcaptcha";
      };

      passthru.tests = {inherit (nixosTests.mCaptcha) create-locally bring-your-own-services;};
    };
in
  mcaptcha
