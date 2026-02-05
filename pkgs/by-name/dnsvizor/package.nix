{
  lib,
  fetchFromGitHub,
  pkgsStatic,
  stdenv,
  callPackage,
  overrideCC,
  ...
}:
let
  libMirage = callPackage ./mirage.nix { };
in
libMirage.builds {
  pname = "dnsvizor";
  version = "0-unstable-2025-12-17";
  monorepo-materialized-path = ./monorepo-materialized;
  packages-materialized-path = ./packages-materialized;
  src = fetchFromGitHub {
    owner = "robur-coop";
    repo = "dnsvizor";
    rev = "57dbfa7208c765ba531995d9638f4a68b4cc6c15";
    hash = "sha256-heiCAB+1TlAVa23r1GD6WP2w3Ha8kbqKup/gzJz0EW8=";
    # ideally we should use postPatch, but we cannot
    postFetch = ''
      # TODO(linj) enable test
      # currently tests fail to build if target is not "unix"
      rm -vrf $out/test

      # TODO(linj) remove this patch after dnsvizor#114 is merged
      substituteInPlace $out/config.ml --replace-fail \
        'package ~min:"0.5.0" "metrics";' \
        'package ~min:"0.5.0" "metrics"; package ~min:"0.5.0" "metrics-lwt";'
    '';
  };
  overrideAttrs = finalAttrs: previousAttrs: {
    buildInputs = previousAttrs.buildInputs or [ ] ++ [
      # Some targets, such as hvt, need static GMP (or MPIR)
      (
        (pkgsStatic.gmp.override {
          # This compiles GMP with a GCC compiled with some flag implying --disable-tls
          # Disabling or rather emulating TLS (Thread-Local Storage)
          # is still required as of solo5-hvt-0.9.3 when compiling with OCaml-4
          # to avoid a crash at startup in __gmpn_cpuvec_init at an instruction mov %fs:0x28,%r12
          # accessing %fs (the address of the current thread's user-space thread structure):
          #
          # solo5-hvt-debug --dumpcore=dump --mem=512 --net:service=tap-unikernel -- \
          #   $(nix -L build --print-out-paths --no-link -f. dnsvizor.hvt)/dnsvizor.hvt
          #
          # Solo5: trap: type=#PF ec=0x0 rip=0x466a86 rsp=0x1ffffc10 rflags=0x10002
          # Solo5: trap: cr2=0x28
          # Solo5: ABORT: cpu_x86_64.c:181: Fatal trap
          stdenv = overrideCC pkgsStatic.stdenv pkgsStatic.stdenv.cc.cc;
        }).overrideAttrs
        (prevAttrs: {
          # This is to support cxx = true which is not necessary for DNSvizor,
          # but it's pkgs.gmp's default on most platforms.
          depsBuildBuild = [
            pkgsStatic.stdenv.cc
            pkgsStatic.binutils
          ];
        })
      )
    ];
  };
  query = {
    # follow upstream CI version (.cirrus.yml) because newer ones fail to build
    ocaml-base-compiler = "4.14.2";
  };
  monorepoQuery = {
    uutf = "1.0.3+dune"; # default version is not in the dune overlay yet
  };

  # Explanation: remove broken targets instead of setting meta.broken
  # because it doesn't cover eval failure by IFD.
  # For more detailed support state, see: https://github.com/Solo5/solo5/blob/dabc69fd89b8119449ec4088c54b458d4ccc851b/docs/building.md?plain=1#L55
  targets = lib.subtractLists (
    [
      "genode" # Explanation: removed in solo5 0.7.0
      "macosx"
    ]
    ++ lib.optionals stdenv.hostPlatform.isAarch64 [
      "muen"
      "qubes"
      "virtio"
      "xen"
    ]
  ) libMirage.possibleTargets;
}
