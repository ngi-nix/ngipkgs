{
  lib,
  pkgs,
  sources,
  ...
}@args:
{
  metadata = {
    summary = ''
      Webservice for proximity matching based on TLSH and vantage point trees.
    '';
    subgrants = {
      # Not listed online?
    };
  };

  nixos.modules.services = {
    proximity-matcher = {
      name = "proximity-matcher";
      module = ./module.nix;
      examples.basic = {
        module = ./example.nix;
        description = ''
          Sets up proximity-matcher with a basic configuration for TLSH and a location with known hashes.
        '';
        tests.basic.module = ./test.nix;
      };
      links = {
        readme = {
          text = "Project README";
          url = "https://github.com/armijnhemel/proximity_matcher_webservice/blob/main/README.md";
        };
      };
    };
  };
}
