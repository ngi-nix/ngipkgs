let
  default = import ../. { };
in
import ./. {
  inherit (default)
    lib
    lib'
    system
    projects
    ;
  pkgs = with default; pkgs // ngipkgs;
  nixpkgs = default.sources.nixpkgs;
  options = default.optionsDoc.optionsNix;
  self = {
    lastModifiedDate = "315532800"; # linux epoch
    rev = "main";
    shortRev = "main";
  };
}
