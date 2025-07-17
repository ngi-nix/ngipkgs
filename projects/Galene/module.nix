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
    programs.bash.interactiveShellInit = lib.mkIf (config ? demo && config.demo) ''
      echo "Galène is starting. Please wait ..."
      until systemctl show galene.service | grep -q ActiveState=active; do sleep 1; done
      echo "Galène is ready at http://localhost:${toString cfg.httpPort}"
      echo "Galène group dir is: ${cfg.groupsDir}"
    '';

    networking.firewall.allowedTCPPorts = lib.optionals cfg.openFirewall [
      cfg.httpPort
    ];
  };
}
