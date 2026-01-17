{
  lib,
  pkgs,
  sources,
  ...
}@args:

{
  metadata = {
    summary = "Federated platform for audio streaming, exploration, and publishing.";
    subgrants = {
      Review = [ "Funkwhale" ];
      Entrust = [ "FunkWhale-Federation" ];
      Commons = [ "Funkwhale-AP" ];
    };
    links = {
      homepage = {
        text = "Homepage";
        url = "https://www.funkwhale.audio/";
      };
      docs = {
        text = "Documentation";
        url = "https://docs.funkwhale.audio/";
      };
      source = {
        text = "Source Code";
        url = "https://dev.funkwhale.audio/funkwhale/funkwhale";
      };
    };
  };

  nixos.modules.services = {
    funkwhale = {
      name = "Funkwhale";
      module = ./services/funkwhale/module.nix;
      examples."Basic local configuration" = {
        module = ./services/funkwhale/examples/basic.nix;
        description = ''
          Basic Funkwhale configuration.

          You will still need to create an initial user with `sudo -u funkwhale funkwhale-manage fw users create --superuser`.
        '';
        tests.basic.module = ./services/funkwhale/tests/basic.nix;
      };
    };
  };
  nixos.demo.vm = {
    module = ./services/funkwhale/examples/basic.nix;
    module-demo = ./demo/module-demo.nix;
    usage-instructions = [
      {
        instruction = ''
          Create your initial superuser account in the shell:

          `cd / && sudo -u funkwhale funkwhale-manage fw users create --superuser`
        '';
      }
      {
        instruction = "You can log into the website at <http://localhost:12345>.";
      }
    ];
    tests.demo-basic.module = ./demo/tests/basic.nix;
  };
}
