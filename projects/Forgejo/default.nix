{
  pkgs,
  lib,
  sources,
} @ args: {
  packages = {inherit (pkgs) forgejo;};
  nixos = {
    modules.services.forgejo = "${sources.inputs.nixpkgs}/nixos/modules/services/misc/forgejo.nix";
  };
}
