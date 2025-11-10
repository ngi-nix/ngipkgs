{
  lib,
  stdenv,
  fetchFromGitHub,
  fetchpatch,
  autoconf,
  automake,
  bashNonInteractive,
  curl,
  dpkg,
  fpm,
  ldns,
  libedit,
  libjpeg,
  libks,
  libogg,
  libsndfile,
  libtool,
  libuuid,
  libuv,
  libwebsockets,
  libxcrypt,
  lndir,
  lua,
  openal,
  opencore-amr,
  opusfile,
  pcre,
  perl,
  pkg-config,
  postgresql,
  replaceVars,
  sofia_sip,
  spandsp3,
  speex,
  speexdsp,
  sqlite,
  which,
  yasm,
  zlib,
  bbb-shared-utils,
}:

let
  # Pinning versions to what's expected

  sofia-sip' = sofia_sip.overrideAttrs (oa: rec {
    version = "1.13.17";

    src = fetchFromGitHub {
      owner = "freeswitch";
      repo = "sofia-sip";
      tag = "v${version}";
      hash = "sha256-7QmK2UxEO5lC0KBDWB3bwKTy0Nc7WrdTLjoQYzezoaY=";
    };
  });

  spandsp' = spandsp3.overrideAttrs (oa: {
    version = "0-unstable-2022-01-27";

    src = fetchFromGitHub {
      owner = "freeswitch";
      repo = "spandsp";
      rev = "e59ca8fb8b1591e626e6a12fdc60a2ebe83435ed";
      hash = "sha256-gLtLhzdwRYwg8P+WJOtpwn4b8VCo4NG0Q8sVZKtpGnE=";
    };
  });

  libks' = libks.overrideAttrs (oa: rec {
    version = "2.0.3";

    src = fetchFromGitHub {
      owner = "signalwire";
      repo = "libks";
      tag = "v${version}";
      hash = "sha256-iAgiGo/PMG0L4S/ZqSPL7Hl8akCNyva4JhaOkcHit8w=";
    };
  });

  libwebsockets' = libwebsockets.overrideAttrs (oa: rec {
    pname = "libwebsockets";
    version = "3.2.3";

    src = fetchFromGitHub {
      owner = "bigbluebutton";
      repo = "libwebsockets";
      tag = "v${version}";
      hash = "sha256-hIkZ/NH3vjLZF3i1MGvFZGXV6d5wpydO964tMvkvWCQ=";
    };

    cmakeFlags = (oa.cmakeFlags or [ ]) ++ [
      # In this version, CMakeconfig is too borked when static library build isn't enabled as well
      (lib.cmakeBool "LWS_WITH_STATIC" true)
    ];

    propagatedBuildInputs = (oa.propagatedBuildInputs or [ ]) ++ [
      # Some option from Nixpkgs seems to make this a dependency in the generated headers?
      libuv
    ];

    # BBB builds this by forcing -Wno-error, fetched version lacks commit to disable -Werror
    env.NIX_CFLAGS_COMPILE = toString [
      "-Wno-error"
    ];

    # new patches have been added to Nixpkgs that don't apply here
    patches = [ ];
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
  version = bbb-shared-utils.versionComponent;

  inherit (bbb-shared-utils) src;

  patches = [
    (replaceVars ./9901-bbb-freeswitch-core-Use-prebuilt-projects.patch {
      lndirExe = lib.getExe lndir;
      sofia-sip = sofia-sip';
      spandsp = spandsp';
      libks = libks';
      libwebsockets = libwebsockets';
      inherit
        drachtio-freeswitch-modules
        ;
      sofiaSipCheckout = sofia-sip'.src.tag;
      spandspCheckout = spandsp'.src.rev;
      libksCheckout = libks'.src.tag;
      libwebsocketsCheckout = libwebsockets'.src.tag;
      drachtioFreeswitchModulesCheckout = drachtio-freeswitch-modules.rev;
    })
  ];

  postPatch = bbb-shared-utils.postPatch + ''
    patchShebangs freeswitch/libs/libvpx/build/make/rtcd.pl
    # Follow our parallelism settings, and apply any other ones
    # Take installed freeswitch from location that isn't global /opt
    # Symlink sofia-sip tools
    # Symlink libraries from deps
    substituteInPlace build/packages-template/bbb-freeswitch-core/build.sh \
      --replace-fail 'make -j $(nproc)' 'make ''${enableParallelBuilding:+-j $NIX_BUILD_CORES} ''${makeFlags[@]} ''${buildFlags[@]}' \
      --replace-fail 'make install' 'make ''${enableParallelInstalling:+-j $NIX_BUILD_CORES} ''${makeFlags[@]} ''${installFlags[@]} install' \
      --replace-fail 'cp -r /opt' 'cp -r ${freeswitchDestdir}/opt' \
      --replace-fail 'cp /usr/local/bin/$file $DESTDIR/opt/freeswitch/bin' 'ln -vs ${sofia-sip'}/bin/$file $DESTDIR/opt/freeswitch/bin/$file' \
      --replace-fail 'cp -P /usr/local/lib/lib* $DESTDIR/opt/freeswitch/lib' 'for dep in ${sofia-sip'} ${spandsp'} ${libks'} ${libwebsockets'}; do for depLib in $dep/lib/lib*; do ln -vs $depLib $DESTDIR/opt/freeswitch/lib/$(basename $depLib); done; done'

    # Assembly doesn't work unless using yasm. Dunno why, libvpx package does the same.
    substituteInPlace freeswitch/Makefile.am \
      --replace-fail \
        'cd libs/libvpx && CC="$(CC)" CXX="$(CXX)" CFLAGS="$(CFLAGS) $(VISIBILITY_FLAG)" CXXFLAGS="$(CXXFLAGS)" LDFLAGS="$(LDFLAGS)" ./configure' \
        'cd libs/libvpx && CC="$(CC)" CXX="$(CXX)" CFLAGS="$(CFLAGS) $(VISIBILITY_FLAG)" CXXFLAGS="$(CXXFLAGS)" LDFLAGS="$(LDFLAGS)" ./configure --as=yasm'
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

    libks'
    libwebsockets'
    sofia-sip'
    spandsp'
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
    sofia-sip = sofia-sip';
    spandsp = spandsp';
    libks = libks';
    libwebsockets = libwebsockets';
    inherit
      drachtio-freeswitch-modules
      ;
  };

  meta = bbb-shared-utils.meta // {
    description = bbb-shared-utils.meta.description + " (bbb-freeswitch-core)";
  };
})
