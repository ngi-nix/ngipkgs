{
  lib,
  pkgs,
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

  # TODO: remove
  demo-vm =
    module:
    pkgs.writeShellScript "demo-vm" ''
      exec ${(eval module).config.system.build.vm}/bin/run-nixos-vm "$@"
    '';

  demo-shell = module: (eval module).config.shells.bash.activate;
}
