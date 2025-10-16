{
  lib,
  stdenvNoCC,
  callPackage,
  fetchFromGitHub,
  fetchpatch,
  writeShellApplication,
  bashInteractive,
  ghdl,
  gnat-bootstrap,
  openfpgaloader,
  pkgs,
  pypy310,
  python3Packages,
  yosys,
  yosys-ghdl,
  nix-update-script,
}:

let
  # Adapted from upstream's flake.nix outputs.packages
  nextpnr-xilinx = callPackage ./nix/nextpnr-xilinx.nix { };
  prjxray = callPackage ./nix/prjxray.nix { };
  fasm = callPackage ./nix/fasm {
    inherit fetchpatch;
    inherit (python3Packages)
      buildPythonPackage
      pythonOlder
      textx
      cython
      ;
  };
  nextpnr-xilinx-chipdb = {
    artix7 =
      (callPackage ./nix/nextpnr-xilinx-chipdb.nix {
        backend = "artix7";
        nixpkgs = pkgs;
        inherit nextpnr-xilinx;
        inherit prjxray;
      }).overrideAttrs
        (oa: {
          pname = "${oa.pname}-artix7";
        });
    kintex7 =
      (callPackage ./nix/nextpnr-xilinx-chipdb.nix {
        backend = "kintex7";
        nixpkgs = pkgs;
        inherit nextpnr-xilinx;
        inherit prjxray;
      }).overrideAttrs
        (oa: {
          pname = "${oa.pname}-kintex7";
        });
    spartan7 =
      (callPackage ./nix/nextpnr-xilinx-chipdb.nix {
        backend = "spartan7";
        nixpkgs = pkgs;
        inherit nextpnr-xilinx;
        inherit prjxray;
      }).overrideAttrs
        (oa: {
          pname = "${oa.pname}-spartan7";
        });
    zynq7 =
      (callPackage ./nix/nextpnr-xilinx-chipdb.nix {
        backend = "zynq7";
        nixpkgs = pkgs;
        inherit nextpnr-xilinx;
        inherit prjxray;
      }).overrideAttrs
        (oa: {
          pname = "${oa.pname}-zynq7";
        });
  };

  # Adapted from upstream's flake.nix outputs.devShell
  shellScript = writeShellApplication {
    name = "openxc7-env";
    runtimeInputs = [
      fasm
      prjxray
      nextpnr-xilinx

      yosys
      ghdl
      yosys-ghdl
      openfpgaloader
      pypy310
    ]
    ++ (with python3Packages; [
      pyyaml
      textx
      simplejson
      intervaltree
    ]);
    runtimeEnv = {
      "NEXTPNR_XILINX_DIR" = "${nextpnr-xilinx}";
      "NEXTPNR_XILINX_PYTHON_DIR" = "${nextpnr-xilinx}/share/nextpnr/python/";
      "PRJXRAY_DB_DIR" = "${nextpnr-xilinx}/share/nextpnr/external/prjxray-db";
      "PRJXRAY_PYTHON_DIR" = "${prjxray}/usr/share/python3/";
      "PYTHONPATH" = lib.strings.concatStringsSep ":" [
        "${prjxray}/usr/share/python3"
        (python3Packages.makePythonPath (
          [
            fasm
          ]
          ++ (with python3Packages; [
            textx
            arpeggio
            pyyaml
            simplejson
            intervaltree
            sortedcontainers
          ])
        ))
      ];
      "PYPY3" = lib.getExe pypy310;
      "SPARTAN7_CHIPDB" = "${nextpnr-xilinx-chipdb.spartan7}";
      "ARTIX7_CHIPDB" = "${nextpnr-xilinx-chipdb.artix7}";
      "KINTEX7_CHIPDB" = "${nextpnr-xilinx-chipdb.kintex7}";
      "ZYNQ7_CHIPDB" = "${nextpnr-xilinx-chipdb.zynq7}";
    };
    text = ''
      exec ${lib.getExe bashInteractive} "$@"
    '';
  };
in
stdenvNoCC.mkDerivation (finalAttrs: {
  pname = "openxc7";
  version = "0.8.2-unstable-2025-04-03";

  # We can't use upstream's files via fetched src without introducing IFD
  # or pushing the building onto the user - which makes internet-less VM testing
  # hard. This is only here to show the base from which the above code was
  # copied from.
  src = fetchFromGitHub {
    owner = "openXC7";
    repo = "toolchain-nix";
    rev = "b2ca2c45c8a4919fffe04a8716654dc9bba6c7c1";
    hash = "sha256-M4nlDnuFiOVDQvd360NsRPU7jsepIvehEHvIyL/uCSc=";
  };

  dontUnpack = true;
  dontConfigure = true;
  dontBuild = true;

  installPhase = ''
    runHook preInstall

    install -Dm755 ${lib.getExe shellScript} $out/bin/${shellScript.meta.mainProgram}

    runHook postInstall
  '';

  passthru.packages = {
    inherit
      nextpnr-xilinx
      prjxray
      fasm
      ;
    inherit (nextpnr-xilinx-chipdb)
      artix7
      kintex7
      spartan7
      zynq7
      ;
  };

  env.CMAKE_POLICY_VERSION_MINIMUM = "3.5";

  passthru.updateScript = nix-update-script { extraArgs = [ "--version=branch" ]; };

  meta = {
    description = "Open-source FPGA toolchain for AMD/Xilinx Series 7 chips";
    homepage = "https://github.com/openXC7/toolchain-nix";
    # for the toolchain repo, individual packages have their appropriate licenses
    license = lib.licenses.mit;
    inherit (shellScript.meta) mainProgram;
    platforms = lib.platforms.linux;
    # ghdl -> gnat -> gnat-bootstrap only available for very specific platforms
    # Mark broken if bootstrapping gnat is unavailable, to keep CI green
    broken = !lib.meta.availableOn stdenvNoCC.hostPlatform gnat-bootstrap;
  };
})
