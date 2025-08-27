{
  lib,
  system,
  sources,
  nixos-modules,
  demo-modules,
}:
rec {
  eval =
    module:
    import (sources.nixpkgs + "/nixos/lib/eval-config.nix") {
      inherit system;
      modules = [
        module
        (sources.nixpkgs + "/nixos/modules/profiles/qemu-guest.nix")
        (sources.nixpkgs + "/nixos/modules/virtualisation/qemu-vm.nix")
      ]
      ++ nixos-modules
      ++ demo-modules;
      specialArgs = { inherit sources; };
    };

  demo = module: (eval module).config.activate;
}
