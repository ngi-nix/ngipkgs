{ pkgs, ... }:
{
  services.reaction = {
    enable = true;
    settingsFiles = [ ./example-ssh.jsonnet ];
    # Prefer `runAsRoot` to `false` in a production deployment, this is just for the demo
    runAsRoot = true;
    # and give the reaction user and service the proper permissions (see the non-root example, below).
  };
}
