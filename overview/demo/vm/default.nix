{
  lib,
  pkgs,
  config,
  ...
}:
let
  inherit (lib)
    types
    mkOption
    ;
in
{
  imports = [
    ./services.nix
    ./users.nix
    ./virtualisation.nix
  ];

  options = {
    demo-vm.activate = mkOption {
      type = with types; nullOr package;
      default = null;
      apply =
        self:
        pkgs.writeShellScript "demo-vm" ''
          exec ${config.system.build.vm}/bin/run-nixos-vm "$@"
        '';
    };
  };

  config = {
    services.getty.helpLine = ''

      Welcome to NGIpkgs!

      - To exit the demo VM, run: `sudo poweroff`
    '';

    system.stateVersion = "25.05";
  };
}
