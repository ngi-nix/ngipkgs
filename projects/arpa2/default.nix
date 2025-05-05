{
  lib,
  pkgs,
  sources,
}@args:

{
  metadata = {
    summary = "An umbrella for open source projects that implement the open source and open networking ideals of a secure, private and decentral Internet";
    subgrants = [
      "DANCE4All"
      "LDAPmiddleware"
      "SASL-XMSS"
      "SASLworks"
      "Steamworks"
      "TLS-KDH-mbed"
      "arpa2"
      "arpa2-nginx"
      "steamworks"
    ];
  };

  nixos.programs = {
    arpa2 = {
      module = ./module.nix;
      examples.basic = {
        module = ./example.nix;
        description = "";
        tests.basic = null;
      };
    };
  };
}
