inputs: final: prev:
with final.pkgs; {
  arpa2cm = callPackage ./pkgs/arpa2cm { src = inputs.arpa2cm-src; };
  arpa2common =
    callPackage ./pkgs/arpa2common { src = inputs.arpa2common-src; };
  steamworks = callPackage ./pkgs/steamworks { src = inputs.steamworks-src; };
  steamworks-pulleyback = callPackage ./pkgs/steamworks-pulleyback {
    src = inputs.steamworks-pulleyback-src;
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
