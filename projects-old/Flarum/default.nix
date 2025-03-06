{
  pkgs,
  sources,
  ...
}:
{
  packages = { inherit (pkgs) flarum; };
  nixos = {
    modules.services.flarum = "${sources.inputs.nixpkgs}/nixos/modules/services/web-apps/flarum.nix";
    tests = null;
    examples = null;
  };
}
