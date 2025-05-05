{
  sources,
  pkgs,
  ...
}:

let 
  certs = pkgs.runCommand "galene-certs" {} ''
    mkdir -p $out
    ${pkgs.openssl}/bin/openssl req -x509 -newkey rsa:4096 -keyout $out/key.pem -out $out/cert.pem -days 365 -nodes -subj '/CN=localhost'
  '';
in
{
  name = "galene";

  nodes = {
    machine =
      { config, pkgs, ... }:
      {
        imports = [
          sources.modules.ngipkgs
          sources.modules.services.galene
          sources.examples.Galene.galene
        ];

        environment.etc."galene/cert.pem".source = "${certs}/cert.pem";
        environment.etc."galene/key.pem".source = "${certs}/key.pem";
        services.galene = {
          enable = true;
          httpPort = 8443;
          certFile = "/etc/galene/cert.pem";
          keyFile = "/etc/galene/key.pem";
        };
      };
  };

  testScript =
    { nodes, ... }:
    ''
      start_all()
      machine.waitForUnit("galene.service")
      machine.wait_for_open_port(8443)
      machine.succeed("curl --insecure https://localhost:8443 -s -o /dev/null -w '%{http_code}' | grep 200")
    '';
}