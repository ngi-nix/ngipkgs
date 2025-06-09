{
  lib,
  config,
  modulesPath,
  ...
}:
let
  cfg = config.services.cryptpad;
in
{
  imports = [
    "${modulesPath}/services/web-apps/cryptpad.nix"
  ];

  # TODO: add to nixpkgs
  options.services.cryptpad.openPorts = lib.mkOption {
    type = lib.types.bool;
    default = false;
    description = ''
      Whether to open the port specified in `settings.httpPort` in the firewall.
    '';
  };
  config = lib.mkIf cfg.openPorts {
    networking.firewall.allowedTCPPorts = [ cfg.settings.httpPort ];
    networking.firewall.allowedUDPPorts = [ cfg.settings.httpPort ];
  };
}
