let
  flake = import ./. {
    src = ../..;
  };
in
  builtins.mapAttrs (_: v: v.outPath) flake.defaultNix.inputs
