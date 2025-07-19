{
  lib,
  pkgs,
  system,
  sources,
  nixos-modules,
  all-the-demo-modules,
}:
let
  eval =
    demo-module:
    import (sources.nixpkgs + "/nixos/lib/eval-config.nix") {
      inherit system;
      modules =
        [
          demo-module
          (sources.nixpkgs + "/nixos/modules/profiles/qemu-guest.nix")
          (sources.nixpkgs + "/nixos/modules/virtualisation/qemu-vm.nix")
        ]
        ++ nixos-modules
        ++ all-the-demo-modules;
      specialArgs = {
        inherit sources;
      };
    };

  demo-vm = module: (eval module).config.demo-vm.activate;
  demo-shell = module: (eval module).config.shells.bash.activate;
in
{
  inherit
    eval
    demo-vm
    demo-shell
    ;
}
