{
  lib,
  stdenv,
  fetchFromGitHub,
  fetchpatch,
  autoconf,
  automake,
  bashNonInteractive,
  check,
  cmake,
  ctestCheckHook,
  curl,
  dpkg,
  fftw,
  fpm,
  ldns,
  libedit,
  libjpeg,
  libogg,
  libpcap,
  libsndfile,
  libtiff,
  libtool,
  libuuid,
  libxcrypt,
  libxml2,
  lndir,
  lua,
  netpbm,
  openal,
  opencore-amr,
  openssl,
  opusfile,
  pcre,
  perl,
  pkg-config,
  postgresql,
  procps,
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
  bbb-shared-utils,
}:

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
      ./2001-sofia-sip-Disable-some-tests.patch
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
      libjpeg
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

    # Issues with asset generation under heavy parallelism
    enableParallelBuilding = false;

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

    patches = [
      # Fix stack smashing in testq with high core count
      (fetchpatch {
        url = "https://github.com/signalwire/libks/commit/404206ca50e2a1b6d9304ca385eec57e8e8955b2.patch";
        hash = "sha256-JIeUU9wNju9W8QhkYXT+e/Zx1GMhDn68gzwQlENB6d0=";
      })
    ];

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

    disabledTests = [
      # [ERROR] [...] testhttp.c:95    init_ssl [...] SSL ERR: CERT CHAIN FILE ERROR
      "testhttp"
    ];

    doCheck = stdenv.buildPlatform.canExecute stdenv.hostPlatform;

    # Something seems to go wrong with testwebsock2 when using parallelism
    enableParallelChecking = false;

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

      # https://github.com/NixOS/nixpkgs/commit/5c92060a39799da7a6edaae78ac7e982e5121188
      for f in $(find . -name CMakeLists.txt); do
        sed '/^cmake_minimum_required/Is/VERSION [0-9]\.[0-9]/VERSION 3.5/' -i "$f"
      done
    '';

    strictDeps = true;

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

    cmakeFlags = [
      (lib.cmakeBool "LWS_WITH_MINIMAL_EXAMPLES" finalAttrs.finalPackage.doCheck)
    ];

    # BBB builds this by forcing -Wno-error, fetched version lacks commit to disable -Werror
    env.NIX_CFLAGS_COMPILE = toString [
      "-Wno-error"
    ];

    # Has some network-related tests that fail. Newer versions have a CMake option to skip
    # tests that require internet, so maybe that's what's making these fail.
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
      teams = [
        lib.teams.ngi
      ];
      platforms = lib.platforms.linux;
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
  version = bbb-shared-utils.versionComponent;

  inherit (bbb-shared-utils) src;

  patches = [
    (replaceVars ./9901-bbb-freeswitch-core-Use-prebuilt-projects.patch {
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
      --replace-fail 'cp /usr/local/bin/$file $DESTDIR/opt/freeswitch/bin' 'ln -vs ${sofia-sip}/bin/$file $DESTDIR/opt/freeswitch/bin/$file' \
      --replace-fail 'cp -P /usr/local/lib/lib* $DESTDIR/opt/freeswitch/lib' 'for dep in ${sofia-sip} ${spandsp} ${libks} ${libwebsockets}; do for depLib in $dep/lib/lib*; do ln -vs $depLib $DESTDIR/opt/freeswitch/lib/$(basename $depLib); done; done'

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

  meta = bbb-shared-utils.meta // {
    description = bbb-shared-utils.meta.description + " (bbb-freeswitch-core)";
  };
})
