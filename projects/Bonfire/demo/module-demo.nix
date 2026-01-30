{
  lib,
  config,
  ...
}:
let
  cfg = config.services.bonfire;
  servicePort = 18000;
in
{
  config = lib.mkIf cfg.enable {
    programs.bash.interactiveShellInit = ''
      echo "Bonfire is starting. Please wait ..."
      until systemctl show bonfire.service | grep -q ActiveState=active; do sleep 1; done
      echo "Bonfire is ready at http://localhost:${toString servicePort}"
    '';

    virtualisation.forwardPorts = [
      {
        from = "host";
        host.port = servicePort;
        guest.port = 80;
      }
    ];
  };
}
