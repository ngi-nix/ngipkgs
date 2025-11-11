{
  lib,
  pkgs,
  system,
  sources,
  projects,
  nixos-modules,
}:
let
  raw-demos = lib.pipe projects [
    (lib.mapAttrs (_: value: value.nixos.demo.vm or value.nixos.demo.shell or null))
    (lib.filterAttrs (_: value: value != null))
  ];

  demo-modules = lib.pipe raw-demos [
    (lib.mapAttrsToList (_: value: value.module-demo.imports))
    (lib.flatten)
  ];

  isFLake = !builtins ? currentSystem;
in
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

  demo-vm =
    module:
    pkgs.writeShellScript "demo-vm" (
      let
        nixos-vm = (eval module).config.system.build.vm;
      in
      if isFLake then
        nixos-vm
      else
        ''
          exec ${nixos-vm}/bin/run-nixos-vm "$@"
        ''
    );
  demo-shell = module: (eval module).config.shells.bash.activate;
  demo = d: (if d.type == "vm" then demo-vm else demo-shell) d.module;

  demos = lib.mapAttrs (_: demo) raw-demos;
}
