{ pkgs, ... }:
{
  config = {
    services.reaction = {
      enable = true;
      stopForFirewall = true; # with this enabled restarting firewall will restart reaction
      settingsFiles = [
        # supports jsonnet as well as yml config formats
        "${pkgs.reaction}/share/examples/example.jsonnet"
        # "${pkgs.reaction}/share/examples/example.yml"
      ];
      runAsRoot = true;
    };
    networking.firewall.enable = true;
  };
}
