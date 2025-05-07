{
  lib,
  pkgs,
  sources,
}@args:
{
  metadata = {
    summary = "Marginalia Search is an experimental search engine focused on the independent web, designed to run on low-cost hardware. Its development aims to improve search quality, expand coverage, automate operations, and provide portable data to support related search projects.";
    subgrants = [
      "Marginalia"
      "Marginalia-multilingual"
    ];
  };

  nixos.services = {
    marginalia-search = {
      name = "marginalia-search";
      module = ./module.nix;
      examples.marginalia-search = {
        module = ./example.nix;
        description = ''
          A basic configuration of a MySQL database, Zookeeper, and Marginalia.

          This configuration will allow opening the control panel at <http://127.0.0.1:7000>.

          Insecure practices are used here to make testing easy.
          For production usage, look into secrets management via Nix.
        '';
        tests.marginalia-search = import ./test.nix args;
      };
    };
  };
}
