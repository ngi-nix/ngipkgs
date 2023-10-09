inputs: sources: final: prev:
with final.pkgs; rec {
  helpers = import ./lib {inherit (final) pkgs stdenv lib;};

  steamworks = callPackage ./pkgs/steamworks {
    src = sources.steamworks-src;
    pname = inputs.steamworks-src.repo;
    version = inputs.steamworks-src.ref;
  };

  steamworks-pulleyback = callPackage ./pkgs/steamworks-pulleyback {
    src = sources.steamworks-pulleyback-src;
    pname = inputs.steamworks-pulleyback-src.repo;
    version = inputs.steamworks-pulleyback-src.ref;
  };

  lillydap = callPackage ./pkgs/lillydap {
    src = sources.lillydap-src;
    pname = inputs.lillydap-src.repo;
    version = inputs.lillydap-src.ref;
  };

  leaf = callPackage ./pkgs/leaf {
    src = sources.leaf-src;
    pname = inputs.leaf-src.repo;
    version = inputs.leaf-src.ref;
  };

  quicksasl = callPackage ./pkgs/quicksasl {
    src = sources.quicksasl-src;
    pname = "quicksasl";
    version = inputs.quicksasl-src.ref;
  };

  tlspool = callPackage ./pkgs/tlspool {
    src = sources.tlspool-src;
    pname = inputs.tlspool-src.repo;
    version = inputs.tlspool-src.ref;
  };

  tlspool-gui = libsForQt5.callPackage ./pkgs/tlspool-gui {
    src = sources.tlspool-gui-src;
    pname = inputs.tlspool-gui-src.repo;
    version = inputs.tlspool-gui-src.ref;
  };

  kip = callPackage ./pkgs/kip {
    src = sources.kip-src;
    pname = inputs.kip-src.repo;
    version = inputs.kip-src.ref;
  };

  freeDiameter = callPackage ./pkgs/freeDiameter {
    src = sources.freeDiameter-src;
    pname = inputs.freeDiameter-src.repo;
    version = inputs.freeDiameter-src.ref;
  };
}
