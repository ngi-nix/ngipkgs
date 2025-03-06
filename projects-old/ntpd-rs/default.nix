{
  pkgs,
  lib,
  sources,
}@args:
{
  packages = {
    inherit (pkgs) ntpd-rs;
  };
  nixos = {
    modules.services.ntpd-rs = "${sources.inputs.nixpkgs}/nixos/modules/services/networking/ntp/ntpd-rs.nix";
    tests.ntpd-rs = "${sources.inputs.nixpkgs}/nixos/tests/ntpd-rs.nix";
    examples = null;
  };
}
