{
  lib,
  fetchFromGitLab,
  fetchurl,
  stdenv,
  bashNonInteractive,
  dpkg,
  fpm,
  sox,
  unzip,
  bbb-shared-utils,
}:

let
  soundsArchive = fetchurl {
    url = "https://web.archive.org/web/20250828125218/https://ubuntu.bigbluebutton.org/sounds.tar.gz";
    hash = "sha256-lm3HZfoLT1BSi6CP6MLRCI+xhztdW8S36baFf3rpx9w=";
  };

  muteUnmute = fetchFromGitLab {
    domain = "gitlab.senfcall.de";
    owner = "senfcall-public";
    repo = "mute-and-unmute-sounds";
    rev = "1dd80acdaecad4c1ee9000449a7ec0a865bbc1b0";
    hash = "sha256-kECVcspro9xwi91rqLY+3MQ0tCGO4iA8CnbkfaB3vR4=";
  };
in
stdenv.mkDerivation (finalAttrs: {
  pname = "bbb-freeswitch-sounds";
  version = bbb-shared-utils.versionComponent;

  inherit (bbb-shared-utils) src;

  postPatch = bbb-shared-utils.postPatch + ''
    substituteInPlace build/packages-template/bbb-freeswitch-sounds/build.sh \
      --replace-fail \
      'wget https://ubuntu.bigbluebutton.org/sounds.tar.gz -O sounds.tar.gz' \
      'ln -vs ${soundsArchive} sounds.tar.gz' \
      --replace-fail \
      'wget https://gitlab.senfcall.de/senfcall-public/mute-and-unmute-sounds/-/archive/master/mute-and-unmute-sounds-master.zip' \
      'ln -vs ${muteUnmute} mute-and-unmute-sounds' \
      --replace-fail 'unzip mute-and-unmute-sounds-master.zip' "" \
      --replace-fail 'pushd mute-and-unmute-sounds-master/sounds' 'pushd mute-and-unmute-sounds/sounds' \
      --replace-fail '-exec /bin/bash' '-exec ${lib.getExe bashNonInteractive}'
  '';

  strictDeps = true;

  nativeBuildInputs = [
    dpkg
    fpm
    sox
    unzip
  ];

  buildInputs = [
    bashNonInteractive
  ];

  buildPhase = ''
    runHook preBuild

    env LOCAL_BUILD=1 build/setup-inside-docker.sh bbb-freeswitch-sounds

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

  meta = bbb-shared-utils.meta // {
    description = bbb-shared-utils.meta.description + " (bbb-freeswitch-sounds)";
  };
})
