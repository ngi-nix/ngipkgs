{ pkgs, ... }:
{
  config = {
    services.reaction = {
      enable = true;
      stopForFirewall = false;
      # example.jsonnet/example.yml can be copied and modified from ${pkgs.reaction}/share/examples
      settingsFiles = [ "${pkgs.reaction}/share/examples/example.jsonnet" ];
      runAsRoot = false;
    };
    services.openssh.enable = true;
    # If not running as root you need to give the reaction user and service the proper permissions

    # allows reading journal logs of processess
    users.users.reaction.extraGroups = [ "systemd-journal" ];

    # allows modifying ip firewall rules
    systemd.services.reaction.unitConfig.ConditionCapability = "CAP_NET_ADMIN";
    systemd.services.reaction.serviceConfig = {
      CapabilityBoundingSet = [ "CAP_NET_ADMIN" ];
      AmbientCapabilities = [ "CAP_NET_ADMIN" ];
    };
  };
}
