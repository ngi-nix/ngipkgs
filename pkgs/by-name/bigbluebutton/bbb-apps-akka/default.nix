{
  mkSbtDerivation,
  dpkg,
  fakeroot,
  makeWrapper,
  jdk,
  bbb-shared-utils,
  bbb-common-message,
}:

mkSbtDerivation {
  pname = "bbb-apps-akka";
  version = bbb-shared-utils.versionComponent;

  inherit (bbb-shared-utils) src;

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

  postPatch = bbb-shared-utils.postPatch + ''
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

  meta = bbb-shared-utils.meta // {
    description = bbb-shared-utils.meta.description + " (bbb-apps-akka)";
  };
}
