{
  lib,
  pkgs,
  sources,
  ...
}@args:
{
  metadata = {
    summary = "Omnom is a webpage bookmarking and snapshotting service.";
    subgrants = [
      "omnom"
      "omnom-ActivityPub"
    ];
  };

  nixos = {
    modules.services = {
      omnom = {
        # https://github.com/asciimoo/omnom/blob/master/config/config.go
        module = lib.moduleLocFromOptionString "services.omnom";
        examples.base = {
          module = ./example.nix;
          description = "Basic Omnom configuration, mainly used for testing purposes";
          tests.basic.module = null;
        };
      };
    };
    demo.vm = {
      module = ./demo.nix;
      description = "Deployment for demo purposes";
      tests.basic.module = null;
    };
  };
}
