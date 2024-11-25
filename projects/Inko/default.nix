{
  pkgs,
  lib,
  sources,
} @ args: {
  packages = {
    inherit (pkgs) inko ivm;
  };
  nixos = {
    examples = null;
  };
}
