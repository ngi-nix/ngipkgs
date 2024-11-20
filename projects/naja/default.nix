{
  pkgs,
  lib,
  sources,
} @ args: {
  packages = {
    inherit (pkgs) naja libdwarf-lite;
  };
}
