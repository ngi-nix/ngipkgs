{
  stdenv,
  lib,

  fetchFromGitHub,
  fetchgit,
  fetchurl,
  newScope,
  replaceVars,
  runCommandNoCC,
  unstableGitUpdater,
  writeShellApplication,
  _experimental-update-script-combinators,

  autoconf,
  automake,
  bashNonInteractive,
  bc,
  binwalk,
  bison,
  ccache,
  cmake,
  cpio,
  curl,
  elfutils,
  envsubst,
  flex,
  getopt,
  gnat,
  gnat-bootstrap,
  gnum4,
  gnumake,
  git,
  imagemagick,
  innoextract,
  jq,
  libtool,
  ncurses,
  nix,
  nixfmt-rfc-style,
  nix-prefetch-scripts,
  nss,
  openssl,
  perl,
  pkg-config,
  python3,
  rsync,
  uefi-firmware-parser,
  unzip,
  xz,
  zip,
  zlib,

  brandName ? "Heads",
}:

let
  # Theoretically, it should be possible to extract these in the updateScript by running the corresponding download
  # scripts in /blobs/* with a curl/wget that prints out the given URL, and collecting all the requested URLs & their
  # output names
  blobs = [
    # p8z77-m_pro
    {
      name = "P8Z77-M-PRO-ASUS-2203.zip";
      url = "https://dlcdnets.asus.com/pub/ASUS/mb/LGA1155/P8Z77-M_PRO/P8Z77-M-PRO-ASUS-2203.zip";
      hash = "sha256-uvf1EyJ1QsUH5Gc1M0Zj9joN9b6fZjLXsPDMpdO5+YA=";
    }

    # t440p, w541
    {
      name = "glrg22ww.exe";
      url = "https://download.lenovo.com/pccbbs/mobiles/glrg22ww.exe";
      hash = "sha256-sIm/xml5iAlP/Z2kAntyHzMxNci55x7gpQaoHafeJds=";
    }

    # xx20
    {
      name = "83rf46ww.exe";
      url = "https://download.lenovo.com/ibmdl/pub/pc/pccbbs/mobiles/83rf46ww.exe";
      hash = "sha256-SPGNSfPHx5+lSamA8UaIvCfBhkX2TZtoJ6Fe9cVH0hA=";
    }

    # xx30
    {
      name = "g1rg24ww.exe";
      url = "https://download.lenovo.com/pccbbs/mobiles/g1rg24ww.exe";
      hash = "sha256-9g4ZkOLaK376WKZFUC0i1Qr9l7U6CSeBvu6bAyK2EVM=";
    }

    # xx30/optiplex_7010_9010
    {
      name = "O7010A29.exe";
      url = "https://dl.dell.com/FOLDER05066036M/1/O7010A29.exe";
      curlOptsList = [
        "--user-agent"
        "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/92.0.4515.159 Safari/537.36"
      ];
      hash = "sha256-zrglhsZ82NWTOshYwS4MtS9uDkyzJJ+WTxwM/AbRb1I=";
    }
    {
      name = "sinit.zip";
      url = "http://web.archive.org/web/20230712081031/https://cdrdv2.intel.com/v1/dl/getContent/630744";
      hash = "sha256-sjxea9cL3P3kIVpaJS5WxJZvDgbKzziOZUypBsTs2tE=";
    }

    # xx80
    {
      name = "Inspiron_5468_1.3.0.exe";
      url = "https://dl.dell.com/FOLDER04573471M/1/Inspiron_5468_1.3.0.exe";
      curlOptsList = [
        "--user-agent"
        "Mozilla/5.0 (Windows NT 10.0; rv:91.0) Gecko/20100101 Firefox/91.0"
      ];
      hash = "sha256-3fvFFDBpng38skpgvLW25UgbMl6+zxrBd+BpATGJ5LA=";
    }
    {
      name = "n24th13w.exe";
      url = "https://download.lenovo.com/pccbbs/mobiles/n24th13w.exe";
      hash = "sha256-pQCpP+ajcoqmZ2xw+Yz0Z4XvFdp8WxzNfTpHjRkKKKg=";
    }

    # z220
    {
      name = "sp97120.tgz";
      url = "https://ftp.hp.com/pub/softpaq/sp97001-97500/sp97120.tgz";
      hash = "sha256-AQLVaSOf3BTKhqevxLFtKxJwNAGJC4PhiPNNI4RIcNw=";
    }
  ];
  makeBlobsDir =
    withBlobs:
    runCommandNoCC "blobs-collected" { } (
      ''
        mkdir -p $out
      ''
      + lib.strings.optionalString withBlobs (
        lib.strings.concatMapStringsSep "\n" (details: ''
          ln -vs ${
            fetchurl (
              {
                inherit (details) url hash;
              }
              # For some websites (looking at you Dell), we may need a more normal-looking user agent
              // lib.optionalAttrs (lib.attrsets.hasAttr "curlOptsList" details) {
                inherit (details) curlOptsList;
              }
            )
          } $out/${details.name}
        '') blobs
      )
    );
  deps = import ./deps.nix;
  patches = import ./patches {
    inherit lib replaceVars;
    bashInterpreter = lib.getExe bashNonInteractive;
    buildConfig = stdenv.buildPlatform.config;
    hostConfig = stdenv.hostPlatform.config;
    musl-cross-make-sources = runCommandNoCC "musl-cross-make-sources" { } (
      ''
        mkdir -p $out
      ''
      + lib.strings.concatMapStringsSep "\n" (details: ''
        ln -vs ${
          fetchurl (
            {
              inherit (details) url hash;
            }
            # nix-prefetch-url is not happy with the default store name of the config.sub download
            # It has been overridden to "config.sub" in the updateScript, so apply this here too
            // lib.optionalAttrs (details.name == "config.sub") {
              inherit (details) name;
            }
          )
        } $out/${details.name}
      '') deps.musl-cross-make-deps
    );
    perlInterpreter = lib.getExe perl;
  };
  generic =
    {
      board,
      withBlobs ? false,
      arch ? "x86",
    }:
    stdenv.mkDerivation (finalAttrs: {
      pname = "heads-${board}";
      version = "0.2.1-unstable-2025-04-03";

      src = fetchFromGitHub {
        owner = "linuxboot";
        repo = "heads";
        rev = "c627965397d5511513b4538ae60cdb067b67e519";
        hash = "sha256-2RkAmZLtWfy/dwEkhwsiab8GZTmsa+zm9QtP5bDu25k=";
      };

      patches = [
        (replaceVars ./2001-heads-Take-blobs-from-prefetched-blobsDir.patch.in {
          blobsDir = makeBlobsDir withBlobs;
        })

        ./2002-heads-Adjust-to-binwalk-3.x.patch
      ];

      postPatch = ''
        patchShebangs \
          bin/cpio-clean \
          bin/fetch_coreboot_crossgcc_archive.sh \
          bin/fetch_source_archive.sh \
          bin/prepare_module_config.sh \
          blobs/p8z77-m_pro/download_BIOS_clean.sh \
          blobs/t440p/download-clean-me \
          blobs/w541/download-clean-me \
          blobs/xx20/download_parse_me.sh \
          blobs/xx30/download_clean_me.sh \
          blobs/xx30/optiplex_7010_9010.sh \
          blobs/xx80/download_clean_deguard_me_pad_tb.sh \
          blobs/z220/download_BIOS_clean.sh \

        # Use "python"
        substituteInPlace \
          blobs/t440p/download-clean-me \
          blobs/w541/download-clean-me \
          blobs/xx30/download_clean_me.sh \
          blobs/xx80/download_clean_deguard_me_pad_tb.sh \
          --replace-fail 'python ' 'python3 '

        # Default to 1 thread instead of all available, makeFlags will override as requested
        # Don't inspect system for current loads (gets printed)
        # Don't get current time & date (gets printed)
        substituteInPlace Makefile \
          --replace-fail '$(shell nproc)' '1' \
          --replace-fail "\$(shell uptime | awk '{print \$\$10}')" '1.00' \
          --replace-fail '`date --rfc-3339=seconds`' '"1970-01-01 00:00:00+00:00"'

        # Don't try to download missing deps from various mirrors, just print what was expected & error out
        substituteInPlace bin/fetch_source_archive.sh \
          --replace-fail 'download "$URL" && exit 0' 'echo "Download of $URL missing at $FILE" >&2 && exit 1'

        # Different coreboot versions fetch different archives under the same name
        # Look them up in named subdirs, so archives don't conflict
        substituteInPlace modules/coreboot \
          --replace-fail '"$(COREBOOT_TOOLCHAIN_DIR)" "$(1)" "$(packages)"' '"$(COREBOOT_TOOLCHAIN_DIR)" "$(1)" "$(packages)"/"$(coreboot_module)"'

        # Make Linux build more verbose, so builds on slower hardware don't time out due to lack of output
        substituteInPlace modules/linux \
          --replace-fail 'ARCH=' 'V=1 ARCH='
      '';

      preConfigure = ''
        mkdir -p build/${arch} packages/${arch}
      ''
      + lib.strings.concatMapStringsSep "\n" (
        details:
        let
          download = fetchgit {
            inherit (details) url rev hash;
            fetchSubmodules = true;
          };
          pinnedRev = if details.pinned then details.rev else "";
        in
        ''
          echo "'${download}' -> '$PWD/build/${arch}/${details.name}'"
          cp -r ${download} build/${arch}/${details.name}

          # We copy from store, and need to keep mode for scripts to continue being executable
          # But we also want to write into this copy (i.e. the .canary), so make everything writable
          chmod -R +w build/${arch}/${details.name}

          echo '${details.url}|${pinnedRev}' > build/${arch}/${details.name}/.canary
        ''
      ) deps.modules
      + lib.strings.concatMapStringsSep "\n" (details: ''
        cp -vr --no-preserve=mode ${
          fetchurl {
            inherit (details) url hash;
          }
        } packages/${arch}/${details.name}
      '') deps.pkgs
      + lib.strings.concatMapAttrsStringSep "\n" (
        corebootName: crossgccArchives:
        ''
          mkdir -p packages/${arch}/${corebootName}
        ''
        + lib.strings.concatMapStringsSep "\n" (details: ''
          cp -vr --no-preserve=mode ${
            fetchurl {
              inherit (details) url hash;
            }
          } packages/${arch}/${corebootName}/${details.name}
        '') crossgccArchives
      ) deps.crossgcc-deps
      + lib.strings.concatMapAttrsStringSep "\n" (
        dirname: patchesInDir:
        ''
          mkdir -p patches/${dirname}
        ''
        + lib.strings.concatMapStringsSep "\n" (details: ''
          cp -vr ${details.patch} patches/${dirname}/${details.name}
        '') patchesInDir
      ) patches
      + ''
        # Couldn't patchShebangs before, as they're from a dependency that would've been fetched during build
        patchShebangs \
          build/${arch}/coreboot-*/util/xcompile/xcompile \
          build/${arch}/coreboot-*/util/genbuild_h/genbuild_h.sh
      '';

      strictDeps = true;

      nativeBuildInputs = [
        autoconf
        automake
        bc
        binwalk
        bison
        ccache # only required (for some reason?) by coreboot build
        cmake
        cpio
        curl # coreboot toolchain complains if it's missing
        flex
        gnum4
        git # applying patch files to fetched repos
        imagemagick
        innoextract
        libtool
        ncurses # tic / infocmp when building on non-x86
        perl
        pkg-config
        python3
        rsync
        uefi-firmware-parser
        unzip
        zip
      ]
      # gnat-bootstrap is limited to specific platforms, only include bootstrapped gnat when it should be available
      ++ lib.optionals (lib.meta.availableOn stdenv.buildPlatform gnat-bootstrap) [
        gnat
      ];

      buildInputs = [
        elfutils
        nss
        openssl
        zlib
      ];

      dontUseCmakeConfigure = true;

      enableParallelBuilding = true;

      makeFlags = [
        "BRAND_NAME=${brandName}"
        "HEADS_GIT_VERSION=${finalAttrs.passthru.gitRev}"
        "VERBOSE_REDIRECT=" # Don't hide build output
        "SHELL=${lib.getExe bashNonInteractive}" # Don't look for /usr/bin/env bash
        "AVAILABLE_MEM_GB=4" # Don't inspect system for available memory (gets printed)
        "BOARD=${board}"
      ]
      ++ lib.optionals finalAttrs.enableParallelBuilding [
        # parallelism at global level breaks inter-project deps
        # (i.e. configuring json-c via CMake before the cross compiler it looks for is built)
        "-j1"
      ];

      env = {
        # CMake 4 errors out on old version policies.
        # This is in fetched package sources so very annoying to patch, and Heads so far as no fix for this either.
        CMAKE_POLICY_VERSION_MINIMUM = "3.5";
      };

      preBuild = ''
        # parallelise individual project builds
        # Cannot pass in makeFlags, ncurses subproject "forgets" to expand this and generates invalid bash syntax:
        # ( cd misc && make - -j30 [...] CPUS=$$(NIX_BUILD_CORES) [...] )
        # bash: -c: line 1: syntax error near unexpected token `('
        if [ "''${enableParallelBuilding-1}" ]; then
          makeFlagsArray+=(
            "CPUS=$NIX_BUILD_CORES"
          )
        fi

        export HOME=$TMP

        # Check ahead of building if we have downloaded all package deps that heads manages
        # (doesn't cover everything, i.e. musl-cross-make may fail after coreboot toolchain build,
        # because it tries to wget its deps on its own)
        make packages $makeFlags
      '';

      hardeningDisable = [
        "format" # errors out in gcc's libcpp
      ];

      installPhase = ''
        runHook preInstall

        install -t $out -Dm644 build/${arch}/${board}/${finalAttrs.passthru.romName}

        runHook postInstall
      '';

      passthru = {
        gitRev = lib.strings.substring 0 7 finalAttrs.src.rev;
        romName = "${lib.strings.toLower brandName}-${board}-${finalAttrs.passthru.gitRev}.rom";
        updateSourceScript = unstableGitUpdater {
          tagPrefix = "v";
        };
        updateDepsScript = writeShellApplication {
          name = "heads-deps-update-script";
          runtimeInputs = [
            envsubst
            getopt # running crossgcc's script to get list of archives
            git
            gnumake
            jq
            nix
            nixfmt-rfc-style
            nix-prefetch-scripts
            xz
          ];
          runtimeEnv = {
            storeDir = builtins.storeDir;
            printHeadsVariablesMakefile = ./print-heads-variables.mak;
            printMuslCrossMakeVariablesMakefile = ./print-musl-cross-make-variables.mak;
          };
          text = lib.strings.readFile ./update.sh;
        };
        updateScript = _experimental-update-script-combinators.sequence [
          finalAttrs.passthru.updateSourceScript
          finalAttrs.passthru.updateDepsScript
        ];
      };

      meta = {
        description = "Minimal Linux boot payload that provides a secure, flexible boot environment";
        homepage = "https://osresearch.net";
        license = if withBlobs then lib.licenses.unfree else lib.licenses.gpl2Only;
        platforms = lib.platforms.linux;
        broken =
          let
            # Depends on coreboot-4.11, which wants to pull in an insecure expat version
            coreboot-411-boards = [
              "librem_l1um"
              "UNMAINTAINED_kgpe-d16_server"
              "UNMAINTAINED_kgpe-d16_server-whiptail"
              "UNMAINTAINED_kgpe-d16_workstation"
              "UNMAINTAINED_kgpe-d16_workstation-usb_keyboard"
            ];
          in
          # Not a user input, but let's make sure this doesn't silently bitrot
          assert lib.asserts.assertEachOneOf "meta.broken (boards list)" coreboot-411-boards deps.boards;
          lib.lists.elem board coreboot-411-boards;
      };
    });

  # Change change settings that are passed to genericbuilder function for certain boards
  boardSettingsOverrides = {
    # Talos II is a POWER board
    "UNTESTED_talos-2" = {
      arch = "ppc64";
    };
  };

  generateBoards =
    allowedBoards:
    assert lib.asserts.assertEachOneOf "allowedBoards" allowedBoards deps.boards;
    assert lib.asserts.assertEachOneOf "boardSettingsOverrides"
      (builtins.attrNames boardSettingsOverrides)
      deps.boards;
    lib.attrsets.listToAttrs (
      lib.lists.map (board: {
        name = "${board}";
        value = generic (
          {
            inherit board;
          }
          // lib.optionalAttrs (boardSettingsOverrides ? ${board}) boardSettingsOverrides.${board}
        );
      }) allowedBoards
    );
in
lib.makeScope newScope (
  self:
  let
    # To cut down on CI load, and because boards may fail during the final steps because of missing firmware,
    # only allow a fixed list of boards and slowly increase it.
    # (see: https://github.com/NixOS/nixpkgs/pull/286228#issuecomment-2779598354)
    # These are also boards for which we can definitely distribute the results: no extracting of proprietary firmware needed.
    # Maybe some flakiness in here, keep an eye on this
    # install: cannot change permissions of '/build/source/install/x86/sbin/dmsetup.static': No such file or directory
    # https://github.com/ngi-nix/ngipkgs/pull/1433#issuecomment-3097099430
    allowedBoards = [
      "librem_11"
      "librem_13v2"
      "librem_13v4"
      "librem_14"
      "librem_15v3"
      "librem_15v4"
      "librem_l1um_v2"
      "librem_mini"
      "librem_mini_v2"

      # Too many targets with mostly similar configs, blows up build times on CI
      # Only enable afew to test some combinations of settings
      "qemu-coreboot-fbwhiptail-tpm1-hotp" # Used in VM test
      "qemu-coreboot-fbwhiptail-tpm2-hotp-prod_quiet"
      "qemu-coreboot-whiptail-tpm1"
      "qemu-coreboot-whiptail-tpm2-prod"
    ];
  in
  {
    inherit allowedBoards boardSettingsOverrides generateBoards;
  }
  // generateBoards allowedBoards
)
