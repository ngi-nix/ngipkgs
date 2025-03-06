{
  pkgs,
  lib,
  sources,
  ...
}@args:
{
  packages = {
    inherit (pkgs) wireguard-rs wireguard-go wireguard-tools;
  };
  nixos = {
    modules.services.wireguard = "${sources.inputs.nixpkgs}/nixos/modules/services/networking/wireguard.nix";
    tests =
      lib.foldl'
        (acc: test: acc // { ${test} = "${sources.inputs.nixpkgs}/nixos/tests/wireguard/${test}.nix"; })
        { }
        [
          "basic"
          "namespaces"
          "wg-quick"
          "generated"
        ];
    examples = null;
  };
}
