{
  lib,
  pkgs,
  system,
  sources,
  extendedNixosModules,
}:
let
  eval =
    demo-module:
    import (sources.nixpkgs + "/nixos/lib/eval-config.nix") {
      inherit system;
      modules = [
        demo-module
        (sources.nixpkgs + "/nixos/modules/profiles/qemu-guest.nix")
        (sources.nixpkgs + "/nixos/modules/virtualisation/qemu-vm.nix")
        ./shell.nix
        ./vm
      ] ++ extendedNixosModules;
      specialArgs = { inherit sources; };
    };
in
{
  demo-vm =
    module:
    pkgs.writeShellApplication {
      name = "demo-vm";
      text = ''
        exec ${(eval module).config.system.build.vm}/bin/run-nixos-vm "$@"
      '';
    };

  demo-shell = module: (eval module).config.shells.bash.activate;
}
