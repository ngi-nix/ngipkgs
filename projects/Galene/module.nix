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
      Whether to open the serivce port` in the firewall.
    '';
    default = false;
  };

  config = lib.mkIf cfg.enable {
    programs.bash.interactiveShellInit = lib.mkIf (config ? demo && config.demo) ''
      echo "Galene is starting. Please wait ..."
      until systemctl show galene.service | grep -q ActiveState=active; do sleep 1; done
      echo "Galene is ready at http://localhost:${toString cfg.httpPort}"
    '';

    networking.firewall.allowedTCPPorts = lib.optionals cfg.openFirewall [
      cfg.httpPort
    ];
  };
}
