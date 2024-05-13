{
  callPackage,
  libresoc-nmigen,
}: let
  lib = callPackage ../libresoc-nmigen/lib.nix {};
  inherit (lib) fetchFromLibresoc;

  pinmux = callPackage ./pinmux.nix {inherit fetchFromLibresoc;};
in
  callPackage ./verilog.nix {inherit pinmux libresoc-nmigen;}
