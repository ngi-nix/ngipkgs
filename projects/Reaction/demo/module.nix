{ pkgs, ... }:
{
  services.reaction = {
    enable = true;
    settingsFiles = [ ./example-ssh.jsonnet ];
    runAsRoot = true;
  };
}
