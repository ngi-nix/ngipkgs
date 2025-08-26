{
  lib,
  config,
  ...
}:
let
  cfg = config.services.ratmand;
in
{
  config = lib.mkIf cfg.enable {
    services.ratmand.settings = {
      # For connecting from the host
      ratmand.dashboard_bind = "0.0.0.0:5850";
    };
    # ratmand web dashboard
    networking.firewall.allowedTCPPorts = [ 5850 ];
  };
}
