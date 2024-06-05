let
  flake = import ./. {
    src = ../..;
  };
in
  {
    inherit (flake.defaultNix) lastModifiedDate;
  }
  // (
    if (flake.defaultNix ? rev)
    then {
      inherit (flake.defaultNix) shortRev rev;
    }
    else {
      inherit (flake.defaultNix) dirtyRev;
    }
  )
