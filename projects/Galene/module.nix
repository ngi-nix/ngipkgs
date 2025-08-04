{
  lib,
  pkgs,
  config,
  modulesPath,
  ...
}:
let
  cfg = config.services.galene;
in
{
  imports = [
    "${modulesPath}/services/web-apps/galene.nix"
  ];

  options.services.galene.openFirewall = lib.mkOption {
    type = lib.types.bool;
    description = ''
      Whether to open the service's ports in the firewall.
    '';
    default = false;
  };

  config = lib.mkIf cfg.enable {
    networking.firewall.allowedTCPPorts = lib.optionals cfg.openFirewall [
      cfg.httpPort
    ];
  };
}
