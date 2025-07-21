{
  stdenvNoCC,
  lib,
  fetchFromGitHub,
  runCommandNoCC,
  mkSbtDerivation,
  dpkg,
  fakeroot,
  makeWrapper,
  jdk,
}:

let
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
  src = runCommandNoCC "bigbluebutton-src" { } ''
    cp -vr ${srcBare} $out
    chmod +w $out

    ${lib.strings.concatMapStringsSep "\n" (dep: "cp -vr ${dep.src} $out/${dep.name}") externalDeps}
  '';

  bbb-common-message = mkSbtDerivation {
    pname = "bbb-common-message";
    version = "3.0.10-bigbluebutton";

    inherit src;

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

    postPatch = ''
      patchShebangs build/setup-inside-docker.sh build/packages-template

      # This is for setting up cache persistency in docker across runs. We don't want this.
      substituteInPlace build/setup-inside-docker.sh \
        --replace-fail 'ln -s "''${SOURCE}/cache/''${dir}" "/root/''${dir}"' '#ln -s "''${SOURCE}/cache/''${dir}" "/root/''${dir}"' \
        --replace-fail 'CACHE_DIR="/root/"' 'CACHE_DIR="''${SOURCE}/cache/"'
    '';

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

    inherit src;

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

    postPatch = ''
      patchShebangs build/setup-inside-docker.sh build/packages-template

      # This is for setting up cache persistency in docker across runs. We don't want this.
      substituteInPlace build/setup-inside-docker.sh \
        --replace-fail 'ln -s "''${SOURCE}/cache/''${dir}" "/root/''${dir}"' '#ln -s "''${SOURCE}/cache/''${dir}" "/root/''${dir}"' \
        --replace-fail 'CACHE_DIR="/root/"' 'CACHE_DIR="''${SOURCE}/cache/"'

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
in
{
  inherit bbb-common-message bbb-apps-akka;
}
