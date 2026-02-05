{
  lib,
  fetchFromGitHub,
  pkgsStatic,
  stdenv,
  callPackage,
  overrideCC,
  unstableGitUpdater,
  _experimental-update-script-combinators,
}:
let
  libMirage = callPackage ./mirage.nix { };
in
(libMirage.build (finalAttrs: {
  pname = "dnsvizor";
  version = "0-unstable-2026-01-21";
  materializedDir = ./materialized;
  src = fetchFromGitHub {
    owner = "robur-coop";
    repo = "dnsvizor";
    rev = "0a209647142feeb653deb542cc0177621ab70483";
    hash = "sha256-GuQJzXO2w61nBa9KsnuExBGCEsPZ7lO9hcgPy0UqXRo=";
    # ideally we should use postPatch, but we cannot
    postFetch = ''
      # TODO(linj) enable test
      # currently tests fail to build if target is not "unix"
      rm -vrf $out/test
    '';
  };
  overrideUnikernel = finalAttrs: previousAttrs: {
    buildInputs = previousAttrs.buildInputs or [ ] ++ [
      # Some targets, such as hvt, need static GMP (or MPIR)
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
        # Can be supported by adding pkgsStatic.stdenv.{cc,binutils} to depsBuildBuild
        # but DNSvizor does not need it.
        cxx = false;
      })
    ];
  };
  query = {
    # follow upstream CI version (.cirrus.yml) because newer ones fail to build
    ocaml-base-compiler = "4.14.2";
  };
  # ToDo(maint/update): increase the version boundary asserted
  # or remove the pinned entries when no longer needed.
  # Boundary literals are split in two when they would otherwise
  # be replaced by update-source-version.
  monorepoQuery = {
    # mirage-dnsvizor-hvt> File "duniverse/multipart_form/lib/dune", line 5, characters 31-35:
    # mirage-dnsvizor-hvt> 5 |    base64.rfc2045 prettym pecu uutf fmt angstrom))
    # mirage-dnsvizor-hvt>                                    ^^^^
    # mirage-dnsvizor-hvt> Error: Library "uutf" not found.
    uutf =
      assert lib.versionAtLeast ("0" + "-unstable-2026-01-21") finalAttrs.version;
      "1.0.3+dune"; # default version is not in the dune overlay yet
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
})).overrideAttrs
  (
    finalAttrs: previousAttrs: {
      passthru = previousAttrs.passthru or { } // {
        updateScript = _experimental-update-script-combinators.sequence [
          (unstableGitUpdater { })
          (lib.getExe previousAttrs.passthru.updateScript)
        ];
      };
    }
  )
