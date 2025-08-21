{
  stdenv,
  lib,
  fetchFromGitHub,
  buildNpmPackage,
  mkSbtDerivation,
  runCommand,
  stdenvNoCC,
  autoconf,
  automake,
  bashNonInteractive,
  check,
  cmake,
  ctestCheckHook,
  curl,
  dpkg,
  fakeroot,
  fftw,
  fpm,
  jdk,
  ldns,
  libedit,
  libjpeg,
  libogg,
  libpcap,
  libsecret,
  libsndfile,
  libtiff,
  libtool,
  libuuid,
  libxcrypt,
  libxml2,
  lndir,
  lua,
  makeWrapper,
  netpbm,
  nodejs,
  npmHooks,
  openal,
  opencore-amr,
  openssl,
  opusfile,
  pcre,
  perl,
  pkg-config,
  pnpm_9,
  procps,
  postgresql,
  replaceVars,
  speex,
  speexdsp,
  sox,
  sqlite,
  time,
  util-linux,
  valgrind,
  which,
  yasm,
  zlib,
}:

let
  pnpm = pnpm_9;

  version = "3.0.10";

  # Defined as git clone commands in the *.placeholder.sh files in BBB root
  externalDeps = [
    {
      name = "bbb-etherpad";
      src = fetchFromGitHub {
        owner = "ether";
        repo = "etherpad-lite";
        tag = "1.9.4";
        hash = "sha256-xIwovBrEx9NMI5/v+p6YUAGbv9kMefCqJk+V8x38lvQ=";
      };
    }
    {
      name = "bbb-pads";
      src = fetchFromGitHub {
        owner = "bigbluebutton";
        repo = "bbb-pads";
        tag = "v1.5.3";
        hash = "sha256-9WFDk+a6oSr9kDsqTVWdLuz1PpkHIOeThnfcnvsUgFs=";
      };
    }
    {
      name = "bbb-playback";
      src = fetchFromGitHub {
        owner = "bigbluebutton";
        repo = "bbb-playback";
        tag = "v5.3.5";
        hash = "sha256-XoRQhw8dTRS0C5ZA8lUt6Xk63+h8BtzTPD3fKxriSbM=";
      };
    }
    # This is being fetched pre-built, prolly needs extra treatment for our from-source build
    {
      name = "bbb-presentation-video";
      src = fetchFromGitHub {
        owner = "bigbluebutton";
        repo = "bbb-presentation-video";
        tag = "5.0.0-rc.1";
        hash = "sha256-iGB8GIIvBYgKl87pQq6Dm7/r1jLN32EntiCBdKPXJ2Q=";
      };
    }
    {
      name = "bbb-transcription-controller";
      src = fetchFromGitHub {
        owner = "bigbluebutton";
        repo = "bbb-transcription-controller";
        tag = "v0.2.10";
        hash = "sha256-fRrLF9nKX13rkn/1fLoYSLyFNFu5Md1sOGMlPSvKu/c=";
      };
    }
    {
      name = "bbb-webhooks";
      src = fetchFromGitHub {
        owner = "bigbluebutton";
        repo = "bbb-webhooks";
        tag = "v3.3.1";
        hash = "sha256-ggHBaT93wqf9TvofM+sQKospIJ+1vgiUjgRTBLXAS2U=";
      };
    }
    {
      name = "bbb-webrtc-recorder";
      src = fetchFromGitHub {
        owner = "bigbluebutton";
        repo = "bbb-webrtc-recorder";
        tag = "v0.9.4";
        hash = "sha256-J1OxsWiVa1lRvTyhHDluM6RYZ9zHFNkNLGeDJe1BH6Y=";
      };
    }
    {
      name = "bbb-webrtc-sfu";
      src = fetchFromGitHub {
        owner = "bigbluebutton";
        repo = "bbb-webrtc-sfu";
        tag = "v2.19.0-beta.2";
        hash = "sha256-4GHbbSE7Sa9FsBpumlX4Xj3ls/cL1XZvUgKTzF3ifW8=";
      };
    }
    {
      name = "freeswitch";
      src = fetchFromGitHub {
        owner = "signalwire";
        repo = "freeswitch";
        tag = "v1.10.12";
        hash = "sha256-uOO+TpKjJkdjEp4nHzxcHtZOXqXzpkIF3dno1AX17d8=";
      };
    }
  ];
  srcBare = fetchFromGitHub {
    owner = "bigbluebutton";
    repo = "bigbluebutton";
    tag = "v3.0.10";
    hash = "sha256-r1s+5AFwBrbIUOC+zuWPWNWqiuzHWgBDrWV8JN5bNGM=";
  };

  sharedBbbThings = {
    # For software that isn't BBB itself, to be clear about whose version this is
    version = "${version}-bigbluebutton";

    src = runCommand "bigbluebutton-src" { } ''
      cp -vr ${srcBare} $out
      chmod +w $out

      ${lib.strings.concatMapStringsSep "\n" (dep: "cp -vr ${dep.src} $out/${dep.name}") externalDeps}
    '';

    postPatch = ''
      patchShebangs build/setup-inside-docker.sh build/packages-template

      # This is for setting up cache persistency in docker across runs. We don't want this.
      substituteInPlace build/setup-inside-docker.sh \
        --replace-fail 'ln -s "''${SOURCE}/cache/''${dir}" "/root/''${dir}"' '#ln -s "''${SOURCE}/cache/''${dir}" "/root/''${dir}"' \
        --replace-fail 'CACHE_DIR="/root/"' 'CACHE_DIR="''${SOURCE}/cache/"'
    '';

    meta = {
      description = "Complete web conferencing system for virtual classes and more";
      homepage = "https://bigbluebutton.org";
      license = lib.licenses.lgpl3Only;
      teams = [
        lib.teams.ngi
      ];
      platforms = lib.platforms.linux;
    };
  };

  bbb-common-message = mkSbtDerivation {
    pname = "bbb-common-message";

    inherit (sharedBbbThings) version src postPatch;

    overrideDepsAttrs = final: prev: {
      preBuild = ''
        cd bbb-common-message
      '';
    };

    depsWarmupCommand = ''
      sbt compile
    '';
    depsArchivalStrategy = "copy";
    depsOptimize = false;
    depsSha256 = "sha256-SwtcQrEicIggDBAL51xeHnnPg21Z4wlq8ZyatcFe320=";

    strictDeps = true;

    buildPhase = ''
      runHook preBuild

      cd bbb-common-message

      sbt publishLocal

      runHook postBuild
    '';

    installPhase = ''
      runHook preInstall

      mkdir $out
      cp -t $out/ -r $SBT_DEPS/project/.ivy/local/*

      runHook postInstall
    '';

    meta = sharedBbbThings.meta // {
      description = sharedBbbThings.meta.description + " (bbb-common-message)";
    };
  };

  bbb-apps-akka = mkSbtDerivation {
    pname = "bbb-apps-akka";

    inherit (sharedBbbThings) version src;

    overrideDepsAttrs = final: prev: {
      preBuild = ''
        cd akka-bbb-apps
      '';
    };

    depsWarmupCommand = ''
      mkdir -p $SBT_DEPS/project/.ivy/local
      for thing in ${bbb-common-message}/*; do
        ln -vs "$thing" $SBT_DEPS/project/.ivy/local/"$(basename "$thing")"
      done

      sbt compile

      find $SBT_DEPS/project/.ivy/local -type l -exec rm -v {} \;
    '';
    depsArchivalStrategy = "copy";
    depsOptimize = false;
    depsSha256 = "sha256-duIlX1aEOIfM66Eo4+A0ZdJJ3PLnAbSEC8N9DUUH8Y0=";

    postPatch = sharedBbbThings.postPatch + ''
      # Skipping version mangling & building of dependencies
      substituteInPlace build/packages-template/bbb-apps-akka/build.sh \
        --replace-fail 'EPHEMERAL_VERSION=0.0.$(date +%s)-SNAPSHOT' 'cat <<EOF >/dev/null' \
        --replace-fail 'sed -i "s/EPHEMERAL_VERSION/$EPHEMERAL_VERSION/g" project/Dependencies.scala' 'EOF'
    '';

    strictDeps = true;

    nativeBuildInputs = [
      dpkg
      fakeroot
      makeWrapper
    ];

    buildPhase = ''
      runHook preBuild

      cd akka-bbb-apps

      mkdir -p $SBT_DEPS/project/.ivy/local
      for thing in ${bbb-common-message}/*; do
        ln -vs "$thing" $SBT_DEPS/project/.ivy/local/"$(basename "$thing")"
      done

      sbt debian:packageBin

      find $SBT_DEPS/project/.ivy/local -type l -exec rm -v {} \;

      runHook postBuild
    '';

    # TODO: More hardcoded assumptions in $out/share/bbb-apps-akka/conf/*
    installPhase = ''
      runHook preInstall

      dpkg -x target/*.deb $out

      # Fix up Debian-isms

      # No usr please, we have the prefix for that
      mv -vt $out/ $out/usr/*
      rmdir $out/usr

      # Fix broken symlinks, due to prefix not being / and no more usr
      ln -vfs $out/share/bbb-apps-akka/conf $out/etc/bbb-apps-akka
      ln -vfs $out/share/bbb-apps-akka/bin/bbb-apps-akka $out/bin/bbb-apps-akka

      ln -vfs /var/lib/bbb-apps-akka/logs $out/share/bbb-apps-akka/logs

      # We won't be using this, since it's read-only
      rm -r $out/var/log
      rmdir $out/var # Just to make sure we notice if there's ever smth else worth keeping here

      # Add Nix-isms

      # Add default Java
      wrapProgram $out/share/bbb-apps-akka/bin/bbb-apps-akka \
        --set-default JAVA_HOME ${jdk.home}

      runHook postInstall
    '';

    meta = sharedBbbThings.meta // {
      description = sharedBbbThings.meta.description + " (bbb-apps-akka)";
    };
  };

  bbb-config = stdenv.mkDerivation (finalAttrs: {
    pname = "bbb-config";

    inherit (sharedBbbThings) version src postPatch;

    strictDeps = true;

    nativeBuildInputs = [
      dpkg
      fpm
    ];

    buildInputs = [
      bashNonInteractive
    ];

    buildPhase = ''
      runHook preBuild

      env LOCAL_BUILD=1 build/setup-inside-docker.sh bbb-config

      runHook postBuild
    '';

    # FIXME Missing dependencies of installed scripts
    installPhase = ''
      runHook preInstall

      dpkg -x artifacts/*.deb $out

      # Fix up Debian-isms

      # No usr please, we have the prefix for that
      mv -vt $out/ $out/usr/*
      rmdir $out/usr

      # Add Nix-isms

      runHook postInstall
    '';

    meta = sharedBbbThings.meta // {
      description = sharedBbbThings.meta.description + " (bbb-config)";
    };
  });

  bbb-etherpad =
    let
      plainNpmPackage =
        {
          pname,
          version,
          src,
          sourceRoot ? ".",
          npmPackageName ? pname,
        }:

        runCommand "${pname}-${version}"
          {
            passthru = {
              inherit npmPackageName;
            };
          }
          ''
            mkdir -p $out/lib/node_modules
            cp -r --no-preserve=all ${src}/${sourceRoot} $out/lib/node_modules/${npmPackageName}
          '';

      # These get fetched from HEAD, packed & installed during the build script
      npmExtraDeps = {
        ep_pad_ttl = plainNpmPackage {
          pname = "ep_pad_ttl";
          version = "0-unstable-2021-03-21";

          src = fetchFromGitHub {
            owner = "mconf";
            repo = "ep_pad_ttl";
            rev = "360136cd38493dd698435631f2373cbb7089082d";
            hash = "sha256-cAeEiLULVQjMyd+2LBPIx3zS82Jcsi0FHvjDRAdi/F0=";
          };
        };

        bbb-etherpad-plugin = plainNpmPackage {
          pname = "bbb-etherpad-plugin";
          version = "0-unstable-2022-11-11";

          src = fetchFromGitHub {
            owner = "alangecker";
            repo = "bbb-etherpad-plugin";
            rev = "4dbc28d62c44742ffae79ce88c069802bc533068";
            hash = "sha256-oUw+nIl4/29zOrB1GhuBenvdxLOPXANvMi7Tb9UOgvQ=";
          };

          npmPackageName = "ep_bigbluebutton_patches";
        };

        ep_redis_publisher = buildNpmPackage {
          pname = "ep_redis_publisher";
          version = "0.0.3-unstable-2023-07-24";

          src = fetchFromGitHub {
            owner = "mconf";
            repo = "ep_redis_publisher";
            rev = "2b6e47c1c59362916a0b2961a29b259f2977b694";
            hash = "sha256-KQ+w2QUBNSB3dzBfb9PpbQ1ubDYioZvtAavCMSiobBc=";
          };

          npmDepsHash = "sha256-i/b3PWIUdZUhf5GejDvSjvMPIpytG80pz/k5JAPhNoE=";

          postPatch = ''
            cp -v ${./ep_redis_publisher.package-lock.json} package-lock.json
          '';

          dontBuild = true;

          passthru.npmPackageName = "ep_redis_publisher";
        };

        ep_cursortrace = stdenvNoCC.mkDerivation (finalAttrs: {
          pname = "ep_cursortrace";
          version = "3.1.20-unstable-2025-01-22";

          src = fetchFromGitHub {
            owner = "mconf";
            repo = "ep_cursortrace";
            rev = "56fb8c2b211cdda4fc8715ec99e1cb7b7d9eb851";
            hash = "sha256-rSjEhBpAV44iDZVPx48Rg/abHOYghx4T4rHl3QQYmyg=";
          };

          pnpmDeps = pnpm.fetchDeps {
            inherit (finalAttrs) pname src;
            fetcherVersion = 2;
            hash = "sha256-78cgB+2+30blVIELhOrAyEwJkgIt8TO6CJTKiJFY5rk=";
          };

          strictDeps = true;

          nativeBuildInputs = [
            pnpm.configHook
            nodejs
            npmHooks.npmInstallHook
          ];

          # Seems to hang? Don't know why.
          dontNpmPrune = true;

          passthru.npmPackageName = "ep_cursortrace";
        });

        ep_disable_chat = plainNpmPackage rec {
          pname = "ep_disable_chat";
          version = "0.0.12";

          src = fetchFromGitHub {
            owner = "ether";
            repo = "ether-plugins";
            tag = "ep_disable_chat@v${version}";
            hash = "sha256-8k4EbtlYQvbynsLEiE9ch0GgLTSikzEIyf5qDyoJnj8=";
          };

          sourceRoot = "ep_disable_chat";
        };

        ep_auth_session = plainNpmPackage {
          pname = "ep_auth_session";
          version = "1.1.1";

          src = fetchFromGitHub {
            owner = "Kurounin";
            repo = "ep_auth_session";
            # Not tagged
            rev = "897767d8b077735def09dacd35e0070cce95eaf3";
            hash = "sha256-FlZQiESCkLmK6ZuJ4pz20hS/huW/aOee+VDyOeiHYhA=";
          };
        };
      };

      bbb-etherpad-skin = fetchFromGitHub {
        owner = "alangecker";
        repo = "bbb-etherpad-skin";
        rev = "91b052c2cc4c169f2e381538e4342e894f944dbe";
        hash = "sha256-aQxntcI33SvCKbSmVnr9mEFnbHLezzTWSURtlNHSg4o=";
      };
    in
    buildNpmPackage {
      pname = "bbb-etherpad";

      inherit (sharedBbbThings) version src;

      # > Error: Git dependency node_modules/sqlite3 contains install scripts, but has no lockfile, which is something that will probably break. Open an issue if you can't feasibly patch this dependency out, and we'll come up with a workaround.
      # > If you'd like to attempt to try to use this dependency anyways, set `forceGitDeps = true`.
      # Let's see if we're lucky, and just enable it.
      forceGitDeps = true;
      npmDepsHash = "sha256-dPoRhp1ex9ohMZ/s26C1EBkAuKVX8OqmuV1OeeI1U+8=";

      postPatch = sharedBbbThings.postPatch + ''
        # Don't install a different npm
        # Don't try to install npm deps
        # Use pre-downloaded skin
        # Skip all other git clones
        # Skip packing of additional npm deps
        substituteInPlace build/packages-template/bbb-etherpad/build.sh \
          --replace-fail 'npm i -g npm@6.14.11' 'echo "Not installing a different NPM version"' \
          --replace-fail 'bin/installDeps.sh' 'echo "Letting Nix set up the base NPM deps"' \
          --replace-fail 'git clone https://github.com/alangecker/bbb-etherpad-skin.git' 'cp -r --no-preserve=all ${bbb-etherpad-skin}' \
          --replace-fail 'git clone' 'echo Skipping cloning of:' \
          --replace-fail 'npm pack' 'echo Skipping packing of:' \
          ${
            let
              packedPackage = packageName: "./${packageName}-*.tgz";

              installCall =
                packageName:
                "npm install "
                + lib.optionalString (packageName == "ep_auth_session") "--no-save --legacy-peer-deps "
                + (
                  if (packageName != "ep_disable_chat" && packageName != "ep_auth_session") then
                    packedPackage packageName
                  else
                    packageName
                );
            in
            lib.strings.concatMapAttrsStringSep " " (
              name: value:
              "--replace-fail '${installCall value.passthru.npmPackageName}' 'ln -vs ${value}/lib/node_modules/${value.passthru.npmPackageName} src/node_modules/${value.passthru.npmPackageName}'"
            ) npmExtraDeps
          }

        # For npmDeps to get generated properly
        pushd bbb-etherpad/src
        cp -v ${./etherpad-lite.package-lock.json} package-lock.json
      '';

      strictDeps = true;

      nativeBuildInputs = [
        dpkg
        fpm
        pkg-config
      ];

      buildInputs = [
        libsecret
      ];

      preConfigure = ''
        # No longer setting up npmDeps
        popd
      '';

      buildPhase = ''
        runHook preBuild

        env LOCAL_BUILD=1 build/setup-inside-docker.sh bbb-etherpad

        runHook postBuild
      '';

      # FIXME
      # [ERROR] settings - soffice (libreoffice) does not exist at this path, check your settings file. File location: /usr/share/bbb-libreoffice-conversion/etherpad-export.sh
      # Specified in $out/share/etherpad-lite/settings.json, will need to point at another package's out / a shared root.
      installPhase = ''
        runHook preInstall

        dpkg -x artifacts/*.deb $out

        # Fix up Debian-isms

        # No usr please, we have the prefix for that
        mv -vt $out/ $out/usr/*
        rmdir $out/usr

        substituteInPlace $out/lib/systemd/system/etherpad.service \
          --replace-fail '/usr/share' "$out/share" \
          --replace-fail '/usr/bin/node' '${lib.getExe nodejs}'

        # Add Nix-isms

        runHook postInstall
      '';

      passthru = {
        inherit npmExtraDeps bbb-etherpad-skin;
      };

      meta = sharedBbbThings.meta // {
        description = sharedBbbThings.meta.description + " (bbb-etherpad)";
      };
    };

  bbb-freeswitch-core =
    let
      # Already packaged in Nixpkgs. Repackaged for better control over version, and to enable tests.
      sofia-sip = stdenv.mkDerivation (finalAttrs: {
        pname = "sofia-sip";
        version = "1.13.17";

        src = fetchFromGitHub {
          owner = "freeswitch";
          repo = "sofia-sip";
          tag = "v${finalAttrs.version}";
          hash = "sha256-7QmK2UxEO5lC0KBDWB3bwKTy0Nc7WrdTLjoQYzezoaY=";
        };

        patches = [
          # Disable some tests
          # https://github.com/freeswitch/sofia-sip/issues/234
          # run_addrinfo: Fails due to limited networking during build
          # torture_su_root: Aborts with: bit out of range 0 - FD_SETSIZE on fd_set
          # run_check_nta: Times out in client_2_1_1 test, which seems to test some connection protocol fallback thing
          # run_test_nta: "no valid IPv6 addresses available", likely due to no networking in sandbox
          # check_nua, check_sofia, test_nua: Times out no matter how much time is given to it
          ./sofia-sip-0001-Disable-some-tests.patch
        ];

        postPatch = ''
          # This actually breaks these tests, leading to bash trying to execute bash
          substituteInPlace libsofia-sip-ua/nta/Makefile.am \
            --replace-fail 'TESTS_ENVIRONMENT =' '#TESTS_ENVIRONMENT ='
        '';

        strictDeps = true;

        nativeBuildInputs = [
          autoconf
          automake
          libtool
          pkg-config
        ];

        buildInputs = [
          openssl
        ];

        nativeCheckInputs = [
          valgrind
        ];

        checkInputs = [
          check
          zlib
        ];

        preConfigure = ''
          ./bootstrap.sh
        '';

        configureFlags = [
          (lib.strings.enableFeature true "expensive-checks")
        ];

        env.NIX_CFLAGS_COMPILE = toString [
          # const char *** instead of const char * const**
          "-Wno-error=incompatible-pointer-types"
        ];

        enableParallelBuilding = true;

        doCheck = stdenv.buildPlatform.canExecute stdenv.hostPlatform;

        meta = {
          description = "Open-source SIP User-Agent library, compliant with the IETF RFC3261 specification";
          homepage = "https://github.com/freeswitch/sofia-sip";
          license = lib.licenses.lgpl21Plus;
          teams = [
            lib.teams.ngi
          ];
          platforms = lib.platforms.linux;
        };
      });

      # Already packaged in Nixpkgs. Repackaged for better control over version, and to enable tests.
      spandsp = stdenv.mkDerivation (finalAttrs: {
        pname = "spandsp";
        version = "0-unstable-2022-01-27";

        src = fetchFromGitHub {
          owner = "freeswitch";
          repo = "spandsp";
          rev = "e59ca8fb8b1591e626e6a12fdc60a2ebe83435ed";
          hash = "sha256-gLtLhzdwRYwg8P+WJOtpwn4b8VCo4NG0Q8sVZKtpGnE=";
        };

        postPatch = ''
          patchShebangs autogen.sh

          # pkg-config? What's that?
          substituteInPlace configure.ac \
            --replace-fail '$xml2_include_dir /usr/include /usr/local/include /usr/include/libxml2 /usr/local/include/libxml2' '$xml2_include_dir ${lib.getDev libxml2}/include ${lib.getDev libxml2}/include/libxml2 /usr/local/include/libxml2'
        '';

        strictDeps = true;

        nativeBuildInputs = [
          autoconf
          automake
          libtool
          util-linux
          which
        ];

        # Including spandsp.h includes tiffio.h
        propagatedBuildInputs = [
          libtiff
        ];

        nativeCheckInputs = [
          libtiff
          netpbm
          sox
        ];

        checkInputs = [
          fftw
          libpcap
          libsndfile
          libxml2
        ];

        preConfigure = ''
          ./bootstrap.sh
        '';

        configureFlags = [
          (lib.strings.enableFeature finalAttrs.finalPackage.doCheck "tests")
        ];

        env.NIX_CFLAGS_COMPILE = toString [
          # Missing const conversion on some calls
          "-Wno-error=incompatible-pointer-types"
        ];

        enableParallelBuilding = true;

        doCheck = stdenv.buildPlatform.canExecute stdenv.hostPlatform;

        meta = {
          description = "Low-level signal processing library that modulates and demodulates signals commonly used in telephony";
          homepage = "https://github.com/freeswitch/spandsp";
          license = with lib.licenses; [
            # The library itself
            lgpl21Only

            # The test suite, and some of the supporting code
            gpl2Only
          ];
          teams = [
            lib.teams.ngi
          ];
          platforms = lib.platforms.linux;
        };
      });

      # Already packaged in Nixpkgs. Repackaged for better control over version, and to enable tests.
      libks = stdenv.mkDerivation (finalAttrs: {
        pname = "libks";
        version = "2.0.3";

        src = fetchFromGitHub {
          owner = "signalwire";
          repo = "libks";
          tag = "v${finalAttrs.version}";
          hash = "sha256-iAgiGo/PMG0L4S/ZqSPL7Hl8akCNyva4JhaOkcHit8w=";
        };

        # Please *do* include default compiler paths in your search for math.h, instead of only considering hardcoded
        # FHS paths...
        postPatch = ''
          substituteInPlace cmake/FindLibM.cmake \
            --replace-fail 'NO_DEFAULT_PATH' '# NO_DEFAULT_PATH'
        '';

        strictDeps = true;

        nativeBuildInputs = [
          cmake
          pkg-config
        ];

        buildInputs = [
          libuuid
          openssl
        ];

        nativeCheckInputs = [
          ctestCheckHook
        ];

        doCheck = stdenv.buildPlatform.canExecute stdenv.hostPlatform;

        disabledTests = [
          # [ERROR] [...] testhttp.c:95    init_ssl [...] SSL ERR: CERT CHAIN FILE ERROR
          "testhttp"
        ];

        meta = {
          description = "Foundational support for signalwire C products";
          homepage = "https://github.com/signalwire/libks";
          license = lib.licenses.mit;
          teams = [
            lib.teams.ngi
          ];
          platforms = lib.platforms.linux;
        };
      });

      # Already packaged in Nixpkgs. Repackaged for better control over version, and to enable tests.
      libwebsockets = stdenv.mkDerivation (finalAttrs: {
        pname = "libwebsockets";
        version = "3.2.3";

        src = fetchFromGitHub {
          owner = "bigbluebutton";
          repo = "libwebsockets";
          tag = "v${finalAttrs.version}";
          hash = "sha256-hIkZ/NH3vjLZF3i1MGvFZGXV6d5wpydO964tMvkvWCQ=";
        };

        postPatch = ''
          patchShebangs minimal-examples/selftests.sh

          substituteInPlace minimal-examples/selftests-library.sh \
            --replace-fail '/usr/bin/time' 'time'
        '';

        strictDeps = true;

        cmakeFlags = [
          (lib.cmakeBool "LWS_WITH_MINIMAL_EXAMPLES" finalAttrs.finalPackage.doCheck)
        ];

        nativeBuildInputs = [
          cmake
          openssl
        ];

        buildInputs = [
          openssl
        ];

        nativeCheckInputs = [
          procps
          time
        ];

        # BBB builds this by forcing -Wno-error, fetched version lacks commit to disable -Werror
        env.NIX_CFLAGS_COMPILE = toString [
          "-Wno-error"
        ];

        # Has some network-related tests that fail. Newer versions have a CMake option to skip
        # tests that require internet, so maybe that's what'smaking these fail.
        doCheck = false;

        checkPhase = ''
          runHook preCheck

          ../minimal-examples/selftests.sh

          runHook postCheck
        '';

        meta = {
          description = "Canonical libwebsockets.org networking library";
          homepage = "https://github.com/bigbluebutton/libwebsockets";
          # See https://github.com/bigbluebutton/libwebsockets/blob/626f8816cfb211ec3ccfa56dc9f67af251e130e3/LICENSE
          license = with lib.licenses; [
            # Main
            mit

            # Various sources
            asl20
            bsd2
            bsd3
            cc0
            ofl
            # Otherwise this resolves to the zlib package...
            lib.licenses.zlib
          ];
        };
      });

      # Only a directory gets copied from this, built during bbb-freeswitch-core
      drachtio-freeswitch-modules = fetchFromGitHub {
        owner = "bigbluebutton";
        repo = "drachtio-freeswitch-modules";
        rev = "4198b1c114268829627069afeea7eb40c86a81af";
        hash = "sha256-8Zy5OJWIAlgz+sUkzEBIrmURIqEnQtNZb+y4rm8Qo3I=";
      };

      # DESTDIR setting, so this doesn't try to install to global /opt
      freeswitchDestdir = "/tmp/freeswitch-install-dir";
    in
    stdenv.mkDerivation (finalAttrs: {
      pname = "bbb-freeswitch-core";

      inherit (sharedBbbThings) version src;

      patches = [
        (replaceVars ./bbb-freeswitch-core-9901-Use-prebuilt-projects.patch {
          lndirExe = lib.getExe lndir;
          inherit
            sofia-sip
            spandsp
            libks
            libwebsockets
            drachtio-freeswitch-modules
            ;
          sofiaSipCheckout = sofia-sip.src.tag;
          spandspCheckout = spandsp.src.rev;
          libksCheckout = libks.src.tag;
          libwebsocketsCheckout = libwebsockets.src.tag;
          drachtioFreeswitchModulesCheckout = drachtio-freeswitch-modules.rev;
        })
      ];

      postPatch = sharedBbbThings.postPatch + ''
        patchShebangs freeswitch/libs/libvpx/build/make/rtcd.pl

        # Follow our parallelism settings, and apply any other ones
        # Take installed freeswitch from location that isn't global /opt
        # Symlink sofia-sip tools
        # Symlink libraries from deps
        substituteInPlace build/packages-template/bbb-freeswitch-core/build.sh \
          --replace-fail 'make -j $(nproc)' 'make ''${enableParallelBuilding:+-j $NIX_BUILD_CORES} ''${makeFlags[@]} ''${buildFlags[@]}' \
          --replace-fail 'make install' 'make ''${enableParallelInstalling:+-j $NIX_BUILD_CORES} ''${makeFlags[@]} ''${installFlags[@]} install' \
          --replace-fail 'cp -r /opt' 'cp -r ${freeswitchDestdir}/opt' \
          --replace-fail 'cp /usr/local/bin/$file $DESTDIR/opt/freeswitch/bin' 'ln -vs ${sofia-sip}/bin/$file $DESTDIR/opt/freeswitch/bin/$file' \
          --replace-fail 'cp -P /usr/local/lib/lib* $DESTDIR/opt/freeswitch/lib' 'for dep in ${sofia-sip} ${spandsp} ${libks} ${libwebsockets}; do for depLib in $dep/lib/lib*; do ln -vs $depLib $DESTDIR/opt/freeswitch/lib/$(basename $depLib); done; done'

        # Assembly doesn't work unless using yasm. Dunno why, libvpx package does the same.
        substituteInPlace freeswitch/Makefile.am \
          --replace-fail \
            'cd libs/libvpx && CC="$(CC)" CXX="$(CXX)" CFLAGS="$(CFLAGS) $(VISIBILITY_FLAG)" CXXFLAGS="$(CXXFLAGS)" LDFLAGS="$(LDFLAGS)" ./configure' \
            'cd libs/libvpx && CC="$(CC)" CXX="$(CXX)" CFLAGS="$(CFLAGS) $(VISIBILITY_FLAG)" CXXFLAGS="$(CXXFLAGS)" LDFLAGS="$(LDFLAGS)" ./configure --as=yasm'

        # This package decides to install to global /opt/
      '';

      strictDeps = true;

      nativeBuildInputs = [
        autoconf
        automake
        dpkg
        fpm
        libtool
        perl
        pkg-config
        which
        yasm
      ];

      buildInputs = [
        bashNonInteractive
        curl
        openal
        ldns
        libedit
        libjpeg
        libogg
        libsndfile
        libuuid
        libxcrypt
        lua
        opencore-amr
        opusfile
        pcre
        postgresql
        speex
        speexdsp
        sqlite
        zlib

        libks
        libwebsockets
        sofia-sip
        spandsp
      ];

      env.NIX_CFLAGS_COMPILE = toString [
        # Missing const conversion on some calls
        "-Wno-error=incompatible-pointer-types"
      ];

      buildPhase = ''
        runHook preBuild

        env LOCAL_BUILD=1 build/setup-inside-docker.sh bbb-freeswitch-core

        runHook postBuild
      '';

      enableParallelBuilding = true;

      installFlags = [
        "DESTDIR=${freeswitchDestdir}"
      ];

      installPhase = ''
        runHook preInstall

        dpkg -x artifacts/*.deb $out

        # Fix up Debian-isms

        ls -ahl $out/share/
        ls -ahl $out/share/doc/

        # No usr please, we have the prefix for that
        # Some of the targets already exist via deps, so more specific than usual
        mv -vt $out/bin/ $out/usr/local/bin/*
        rmdir $out/usr/local/bin
        rmdir $out/usr/local
        mv -vt $out/share/doc/ $out/usr/share/doc/bbb-freeswitch-core
        rmdir $out/usr/share/doc
        rmdir $out/usr/share
        rmdir $out/usr

        # Add Nix-isms

        runHook postInstall
      '';

      passthru = {
        inherit
          sofia-sip
          spandsp
          libks
          libwebsockets
          drachtio-freeswitch-modules
          ;
      };

      meta = sharedBbbThings.meta // {
        description = sharedBbbThings.meta.description + " (bbb-freeswitch-core)";
      };
    });
in
{
  inherit
    bbb-common-message
    bbb-apps-akka
    bbb-config
    bbb-etherpad
    bbb-freeswitch-core
    ;
}
