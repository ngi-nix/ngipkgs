{
  lib,
  config,
  ...
}:
let
  cfg = config.services.gancio;
  servicePort = 18000;
in
{
  config = lib.mkIf cfg.enable {
    networking.extraHosts = "0.0.0.0 agenda.example.com";

    virtualisation.forwardPorts = [
      {
        from = "host";
        host.port = servicePort;
        guest.port = 80;
      }
    ];
  };
}
