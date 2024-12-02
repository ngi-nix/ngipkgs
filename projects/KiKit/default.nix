{ pkgs, ... }@args:
{
  packages = {
    inherit (pkgs) kikit;
    inherit (pkgs.kicadAddons) kikit-library;
    kicad-kikit = pkgs.kicadAddons.kikit;
  };
}
