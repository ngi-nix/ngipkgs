{ config, ... }:

{
  programs.eris-go.enable = true;

  system.services.eris = {
    imports = [ config.programs.eris-go.package.passthru.services.eris-server ];
    eris-server.settings = {
      http-decode = true;
      listen-http = "[::]:80";
      listen-coap = [ "[::]:5683" ];
      store-urls = [ "bolt+file:///var/db/eris.bolt?get&put" ];
    };
  };
}
