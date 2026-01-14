{
  lib,
  fetchPnpmDeps,
  pnpmConfigHook,
  buildNpmPackage,
  fetchFromGitHub,
  replaceVars,
  runCommand,
  stdenvNoCC,
  dpkg,
  fpm,
  libsecret,
  nodejs,
  npmHooks,
  pkg-config,
  pnpm_9,
  bbb-shared-utils,
}:

let
  pnpm = pnpm_9;

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

      pnpmDeps = fetchPnpmDeps {
        inherit (finalAttrs) pname src;
        fetcherVersion = 2;
        hash = "sha256-78cgB+2+30blVIELhOrAyEwJkgIt8TO6CJTKiJFY5rk=";
        inherit pnpm;
      };

      strictDeps = true;

      nativeBuildInputs = [
        pnpm
        pnpmConfigHook
        npmHooks.npmInstallHook
        nodejs
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
buildNpmPackage (finalAttrs: {
  pname = "bbb-etherpad";
  version = bbb-shared-utils.versionComponent;

  inherit (bbb-shared-utils) src;

  patches = [
    # Don't install a different npm
    # Don't try to install npm deps
    # Use pre-downloaded skin
    # Skip all other git clones
    # Skip packing of additional npm deps
    (replaceVars ./9901-bbb-etherpad-Use-prebuilt-projects.patch {
      inherit (finalAttrs.passthru.npmExtraDeps)
        ep_pad_ttl
        bbb-etherpad-plugin
        ep_redis_publisher
        ep_cursortrace
        ep_disable_chat
        ep_auth_session
        ;
      inherit (finalAttrs.passthru) bbb-etherpad-skin;

      epPadTtlPackageName = finalAttrs.passthru.npmExtraDeps.ep_pad_ttl.npmPackageName;
      bbbEtherpadPluginPackageName = finalAttrs.passthru.npmExtraDeps.bbb-etherpad-plugin.npmPackageName;
      epRedisPublisherPackageName = finalAttrs.passthru.npmExtraDeps.ep_redis_publisher.npmPackageName;
      epCursortracePackageName = finalAttrs.passthru.npmExtraDeps.ep_cursortrace.npmPackageName;
      epDisableChatPackageName = finalAttrs.passthru.npmExtraDeps.ep_disable_chat.npmPackageName;
      epAuthSessionPackageName = finalAttrs.passthru.npmExtraDeps.ep_auth_session.npmPackageName;
    })
  ];

  # > Error: Git dependency node_modules/sqlite3 contains install scripts, but has no lockfile, which is something that will probably break. Open an issue if you can't feasibly patch this dependency out, and we'll come up with a workaround.
  # > If you'd like to attempt to try to use this dependency anyways, set `forceGitDeps = true`.
  # Let's see if we're lucky, and just enable it.
  forceGitDeps = true;
  npmDepsHash = "sha256-dPoRhp1ex9ohMZ/s26C1EBkAuKVX8OqmuV1OeeI1U+8=";

  postPatch = bbb-shared-utils.postPatch + ''
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

  meta = bbb-shared-utils.meta // {
    description = bbb-shared-utils.meta.description + " (bbb-etherpad)";
  };
})
