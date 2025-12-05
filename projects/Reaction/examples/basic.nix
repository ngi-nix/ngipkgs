{ pkgs, ... }:
{
  config =
    let
      sudoRule = {
        users = [ "reaction" ];
        commands = [
          {
            command = "${pkgs.iptables}/bin/iptables";
            options = [ "NOPASSWD" ];
          }
          {
            command = "${pkgs.iptables}/bin/ip6tables";
            options = [ "NOPASSWD" ];
          }
        ];
        runAs = "root";
      };
    in
    {
      services.reaction = {
        enable = true;
        # TODO maybe move example.jsonnet to pkgs.reaction/share/examples
        settingsFiles = [ ./example.jsonnet ];
        #runAsRoot = true;
      };

      users.users.reaction.extraGroups = [ "systemd-journal" ]; # "wheel" ];

      security.sudo.extraRules = [ sudoRule ];
      security.sudo-rs.extraRules = [ sudoRule ];
    };
}
