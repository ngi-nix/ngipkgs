{
  lib,
  pkgs,
  sources,
  ...
}@args:

{
  metadata = {
    summary = "Open-source framework for building federated digital spaces where people can gather, interact, and form communities online";
    subgrants = {
      Commons = [ ];
      Core = [ ];
      Entrust = [
        "Bonfire-FederatedGroups"
        "Bonfire-Framework"
      ];
      Review = [
        "Bonfire"
      ];
    };
    links = {
      homepage = {
        text = "Home page";
        url = "https://bonfirenetworks.org";
      };
      repo = {
        text = "Source code (only the top-level repository)";
        url = "https://github.com/bonfire-networks/bonfire-app";
      };
      docs = {
        text = "Documentation";
        url = "https://docs.bonfirenetworks.org/readme.html";
      };
    };
  };

  nixos.modules.services = {
    bonfire = {
      name = "service name";
      module = ./services/bonfire/module.nix;
      examples."Enable bonfire" = {
        module = ./services/bonfire/examples/basic.nix;
        description = ''
          Usage instructions

          1. Run `nix -L run -f . hydrated-projects.Bonfire.nixos.tests.basic.driverInteractive`
          2. Open your browser to <http://localhost:4000/signup>
          3. Create an account.
        '';
        tests.basic.module = import ./services/bonfire/tests/basic.nix args;
      };
    };
  };

  nixos.demo.vm = {
    module = ./services/bonfire/examples/basic.nix;
    module-demo = ./demo/module-demo.nix;
    usage-instructions = [
      {
        instruction = ''
          Wait until the service finishes its setup, then visit [http://127.0.0.1:18000](http://127.0.0.1:18000) in your browser
        '';
      }
    ];
    tests.demo.module = null;
  };
}
