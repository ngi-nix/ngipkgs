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
        {
          options.demo = lib.mkOption {
            type = lib.types.bool;
            description = "Whether the configuration should run as a demo.";
            default = false;
          };
          config.demo = true;
        }
      ] ++ extendedNixosModules;
      specialArgs = { inherit sources; };
    };
in
{
  demo-vm =
    module:
    pkgs.writeShellScript "demo-vm" ''
      exec ${(eval module).config.system.build.vm}/bin/run-nixos-vm "$@"
    '';

  demo-shell = module: (eval module).config.shells.bash.activate;
}
