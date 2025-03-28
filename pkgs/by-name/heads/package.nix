{
  stdenv,
  lib,
  fetchgit,
  fetchFromGitHub,
  fetchurl,
  replaceVars,
  runCommandNoCC,
  bashNonInteractive,
  bc,
  bison,
  ccache,
  cmake,
  cpio,
  curl,
  elfutils,
  flex,
  gnum4,
  git,
  imagemagick,
  ncurses,
  perl,
  pkg-config,
  rsync,
  zip,
  zlib,
  brandName ? "Heads",
  board ? "qemu-coreboot-fbwhiptail-tpm1-hotp",
}:

let
  deps = import ./deps.nix;
  patches = import ./patches {
    inherit lib replaceVars;
    musl-cross-make-sources = runCommandNoCC "musl-cross-make-sources" { } (
      ''
        mkdir -p $out
      ''
      + lib.strings.concatMapStringsSep "\n" (details: ''
        ln -vs ${
          fetchurl {
            inherit (details) url hash;
          }
        } $out/${details.name}
      '') deps.musl-cross-make-srcs
    );
    bashInterpreter = lib.getExe bashNonInteractive;
  };
in
stdenv.mkDerivation (finalAttrs: {
  pname = "heads";
  version = "0.2.1-unstable-2025-03-12";

  src = fetchFromGitHub {
    owner = "linuxboot";
    repo = "heads";
    rev = "6279500e5bee5461521964603ab8c5c38812fdf6";
    hash = "sha256-PGGVz2w7B/qjKeTGWVmfmztH9uv7q0e8fdVNBgqsweE=";
  };

  postPatch = ''
    patchShebangs \
      bin/cpio-clean \
      bin/fetch_coreboot_crossgcc_archive.sh \
      bin/fetch_source_archive.sh \
      bin/prepare_module_config.sh

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
  '';

  preConfigure =
    ''
      mkdir -p build/x86 packages/x86
    ''
    + lib.strings.concatMapStringsSep "\n" (
      details:
      let
        download = fetchgit {
          inherit (details) url rev hash;
        };
      in
      ''
        echo "'${download}' -> '$PWD/build/x86/${details.name}'"
        cp -r ${download} build/x86/${details.name}

        # We copy from store, and need to keep mode for scripts to continue being executable
        # But we also want to write into this copy (i.e. the .canary), so make everything writable
        chmod -R +w build/x86/${details.name}

        echo '${details.url}|${details.rev}' > build/x86/${details.name}/.canary
      ''
    ) deps.modules
    + lib.strings.concatMapStringsSep "\n" (details: ''
      cp -vr --no-preserve=mode ${
        fetchurl {
          inherit (details) url hash;
        }
      } packages/x86/${details.name}
    '') deps.pkgs
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
      # FIXME: Hardcoding coreboot-24.12 here isn't great, maybe make "scripts to patch" an optional attribute of modules?
      patchShebangs \
        build/x86/coreboot-24.12/util/xcompile/xcompile \
        build/x86/coreboot-24.12/util/genbuild_h/genbuild_h.sh

      # Print coreboot logs as things happen
      # Don't inspect current system for impure triplets, use stdenv-provided ones
      # TODO: Rewrite as patches, so heads handles this for us
      substituteInPlace build/x86/coreboot-24.12/util/crossgcc/buildgcc \
        --replace-fail '"build_''${package}" "$host_target" > build.log 2>&1' '"build_''${package}" "$host_target" 2>&1 | tee build.log' \
        --replace-fail '/configure' '/configure --build=${stdenv.buildPlatform.config} --host=${stdenv.hostPlatform.config}'
    '';

  strictDeps = true;

  nativeBuildInputs = [
    bc
    bison
    ccache # only required (for some reason?) by coreboot build
    cmake
    cpio
    curl # coreboot toolchain complains if it's missing
    flex
    gnum4
    git # applying patch files to fetched repos
    imagemagick
    ncurses # tic / infocmp when building on non-x86
    perl
    pkg-config
    rsync
    zip
  ];

  buildInputs = [
    elfutils
    zlib
  ];

  dontUseCmakeConfigure = true;

  enableParallelBuilding = true;

  makeFlags =
    [
      "BRAND_NAME=${brandName}"
      "HEADS_GIT_VERSION=${finalAttrs.passthru.gitRev}"
      "VERBOSE_REDIRECT=" # Don't hide build output
      "SHELL=${lib.getExe bashNonInteractive}" # Don't look for /usr/bin/env bash
      "AVAILABLE_MEM_GB=4" # Don't inspect system for available memory (gets printed)
      "BOARD=${board}"
    ]
    ++ lib.optionals finalAttrs.enableParallelBuilding [
      # parallelism at global level breaks inter-project deps
      # (configuring json-c via CMake before the cross compiler it looks for is built)
      "-j1"
    ];

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

    install -t $out -Dm644 build/x86/${board}/${finalAttrs.passthru.romName}

    runHook postInstall
  '';

  passthru = {
    gitRev = lib.strings.substring 0 7 finalAttrs.src.rev;
    romName = "${lib.strings.toLower brandName}-${board}-${finalAttrs.passthru.gitRev}.rom";
  };
})
