{ ... }:

{
  programs.eris-go.enable = true;

  services.eris-server = {
    enable = true;
    decode = true;
    listenHttp = "[::]:80";
    listenCoap = "[::]:5683";
    backends = [ "bolt+file:///var/db/eris.bolt?get&put" ];
  };
}
