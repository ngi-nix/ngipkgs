{
  lib,
  pkgs,
  sources,
}@args:
{
  metadata = {
    summary = ''
      Webservice for proximity matching based on TLSH and vantage point trees.
    '';
    subgrants = [
      # Not listed online?
    ];
  };

  nixos.services = {
    proximity-matcher = {
      name = "proximity-matcher";
      module = ./module.nix;
      examples.basic = {
        module = ./example.nix;
        description = ''
          Sets up proximity-matcher with a basic configuration for TLSH and a location with known hashes.
        '';
        tests.basic = import ./test.nix args;
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
