{
  lib,
  pkgs,
  sources,
  extendedNixosModules,
}:
let
  nixosSystem =
    args:
    import (sources.nixpkgs + "/nixos/lib/eval-config.nix") (
      {
        inherit lib;
        system = null;
      }
      // args
    );

  demo-system =
    module:
    nixosSystem {
      system = "x86_64-linux";
      modules = [
        module
        (sources.nixpkgs + "/nixos/modules/profiles/qemu-guest.nix")
        (sources.nixpkgs + "/nixos/modules/virtualisation/qemu-vm.nix")
        ./vm
      ] ++ extendedNixosModules;
    };

  demo =
    module:
    pkgs.writeShellScript "demo-vm" ''
      exec ${(demo-system module).config.system.build.vm}/bin/run-nixos-vm "$@"
    '';
in
demo
