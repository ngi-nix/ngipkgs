inputs: sources: final: prev:
with final.pkgs; rec {
  helpers = import ./lib {inherit (final) pkgs stdenv lib;};

  steamworks = callPackage ./pkgs/steamworks {};

  steamworks-pulleyback = callPackage ./pkgs/steamworks-pulleyback {};

  lillydap = callPackage ./pkgs/lillydap {};

  leaf = callPackage ./pkgs/leaf {};

  quicksasl = callPackage ./pkgs/quicksasl {};

  tlspool = callPackage ./pkgs/tlspool {};

  tlspool-gui = libsForQt5.callPackage ./pkgs/tlspool-gui {};

  kip = callPackage ./pkgs/kip {};

  freeDiameter = callPackage ./pkgs/freeDiameter {};
}
