{
  pkgs,
  lib,
  sources,
  ...
}@args:
{
  packages = {
    inherit (pkgs) open-web-calendar;
  };
  nixos = {
    modules.services.open-web-calendar = "${sources.inputs.nixpkgs}/nixos/modules/services/web-apps/open-web-calendar.nix";
    tests.open-web-calendar = "${sources.inputs.nixpkgs}/nixos/tests/web-apps/open-web-calendar.nix";
    examples = null;
  };
}
