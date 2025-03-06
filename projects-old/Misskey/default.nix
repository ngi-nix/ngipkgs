{
  pkgs,
  lib,
  sources,
}@args:
{
  packages = {
    inherit (pkgs) misskey;
  };
  nixos = {
    modules.services.misskey = "${sources.inputs.nixpkgs}/nixos/modules/services/web-apps/misskey.nix";
    tests.misskey = "${sources.inputs.nixpkgs}/nixos/tests/misskey.nix";
    examples = null;
  };
}
