{
  lib,
  pkgs,
  sources,
}@args:
{
  metadata = {
    summary = "Omnom is a webpage bookmarking and snapshotting service.";
    subgrants = [
      "omnom"
      "omnom-ActivityPub"
    ];
  };

  nixos.services = {
    omnom = {
      # https://github.com/asciimoo/omnom/blob/master/config/config.go
      module = "${sources.inputs.nixpkgs}/nixos/modules/services/misc/omnom.nix";
      examples.base = {
        module = ./example.nix;
        description = "Basic Omnom configuration, mainly used for testing purposes";
        tests.basic = null;
      };
    };
  };
}
