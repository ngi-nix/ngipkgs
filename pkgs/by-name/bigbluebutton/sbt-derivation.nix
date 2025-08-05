{
  stdenv,
  lib,
  fetchFromGitHub,
  buildNpmPackage,
  mkSbtDerivation,
  runCommand,
  stdenvNoCC,
  bashNonInteractive,
  dpkg,
  fakeroot,
  fpm,
  jdk,
  libsecret,
  makeWrapper,
  nodejs,
  npmHooks,
  pkg-config,
  pnpm_9,
}:

let
  pnpm = pnpm_9;

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
  };

  bbb-common-message = mkSbtDerivation {
    pname = "bbb-common-message";
    version = "3.0.10-bigbluebutton";

    inherit (sharedBbbThings) src postPatch;

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
  };

  bbb-apps-akka = mkSbtDerivation {
    pname = "bbb-apps-akka";
    version = "3.0.10-bigbluebutton";

    inherit (sharedBbbThings) src;

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
  };

  bbb-config = stdenv.mkDerivation (finalAttrs: {
    pname = "bbb-config";
    version = "3.0.10-bigbluebutton";

    inherit (sharedBbbThings) src postPatch;

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
      version = "3.0.10-bigbluebutton";

      inherit (sharedBbbThings) src;

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
    };
in
{
  inherit
    bbb-common-message
    bbb-apps-akka
    bbb-config
    bbb-etherpad
    ;
}
