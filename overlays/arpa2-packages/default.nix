inputs: sources: final: prev:
with final.pkgs; rec {
  helpers = import ./lib { inherit (final) pkgs stdenv; };

  arpa2cm = callPackage ./pkgs/arpa2cm {
    src = sources.arpa2cm-src;
    pname = inputs.arpa2cm-src.repo;
    version = inputs.arpa2cm-src.ref;
  };

  arpa2common = callPackage ./pkgs/arpa2common {
    src = sources.arpa2common-src;
    pname = inputs.arpa2common-src.repo;
    version = inputs.arpa2common-src.ref;
  };

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

  quick-mem = callPackage ./pkgs/quick-mem { src = inputs.quick-mem-src; };

  quick-der = callPackage ./pkgs/quick-der { src = inputs.quick-der-src; };

  lillydap = callPackage ./pkgs/lillydap { src = inputs.lillydap-src; };

  leaf = callPackage ./pkgs/leaf { src = inputs.leaf-src; };

  quick-sasl = callPackage ./pkgs/quick-sasl { src = inputs.quick-sasl-src; };

  tlspool = callPackage ./pkgs/tlspool { src = inputs.tlspool-src; };

  tlspool-gui =
    libsForQt5.callPackage ./pkgs/tlspool-gui { src = inputs.tlspool-gui-src; };

  kip = callPackage ./pkgs/kip { src = inputs.kip-src; };

  freeDiameter =
    callPackage ./pkgs/freeDiameter { src = inputs.freeDiameter-src; };
}
