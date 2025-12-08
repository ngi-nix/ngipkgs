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

    patches = (oa.patches or [ ]) ++ [
      # Fix stack smashing in testq with high core count
      (fetchpatch {
        url = "https://github.com/signalwire/libks/commit/404206ca50e2a1b6d9304ca385eec57e8e8955b2.patch";
        hash = "sha256-JIeUU9wNju9W8QhkYXT+e/Zx1GMhDn68gzwQlENB6d0=";
      })

      # Fixes sometimes-occuring SIGSEGVs in testhash
      (fetchpatch {
        url = "https://github.com/signalwire/libks/commit/61f2d2f7e308c42cce652db4a172cfa4b0ff6bf1.patch";
        hash = "sha256-v14UUPTYkwJ4DEfPnOsHlEUxTJSko5ecD+LMAKh4JQg=";
      })
    ];
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

    postPatch = oa.postPatch or "" + ''
      substituteInPlace CMakeLists.txt \
        --replace-fail \
          "cmake_minimum_required(VERSION 2.8.9)" \
          "cmake_minimum_required(VERSION 3.5)"
    '';

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

    # Abit cursed, but lets us stay on top of patches without a full replacement of the original patches list
    patches =
      let
        # null == patch isn't relevant
        patchReplacements = {
          # Applied in Nixpkgs, fixed in version 4.4. Manually backported.
          "CVE-2025-11677.patch" = ./libwebsockets-0001-v3.2.3-CVE-2025-11677.patch;

          # CVE-2025-11678 fix doesn't apply to this version, relevant functionality was added in 4.0.0
          "CVE-2025-11678.patch" = null;
        };
        getPatchName =
          patchObj:
          {
            "set" = patchObj.name;
            "path" = "${patchObj}";
          }
          .${builtins.typeOf patchObj}
          or (throw "bbb-freecore-switch.passthru.libwebsockets.patches: Unsure how to handle ${builtins.toString patchObj}");
        prevPatches = oa.patches or [ ];
        prevPatchesNames = builtins.map getPatchName prevPatches;
        # patchReplacements attrname -> prevPatchesName
        getPrevPatchName =
          patchName:
          let
            res = builtins.filter (prevPatch: lib.strings.hasSuffix patchName prevPatch) prevPatchesNames;
          in
          if builtins.length res == 1 then builtins.head res else null;
        # patchReplacements, with the original attrnames replaced with the equivalents from prevPatchesNames
        patchReplacementsProcessed = lib.attrsets.concatMapAttrs (
          patchName: patchReplacement:
          let
            prevPatchName = getPrevPatchName patchName;
          in
          assert lib.asserts.assertMsg (prevPatchName != null)
            "bbb-freecore-switch.passthru.libwebsockets.patches: ${patchName} not present in Nixpkgs' libwebsockets.patches!";
          {
            ${prevPatchName} = patchReplacement;
          }
        ) patchReplacements;
      in
      builtins.filter (x: x != null) (
        builtins.map (
          patchElem: patchReplacementsProcessed.${getPatchName patchElem} or patchElem
        ) prevPatches
      );
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
