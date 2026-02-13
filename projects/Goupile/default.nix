{
  lib,
  pkgs,
  sources,
  ...
}@args:

{
  metadata = {
    summary = "Free design tool for Secure forms including Clinical Report Forms (eCRF)";
    subgrants = {
      Core = [ "Goupile" ];
    };
    links = {
      repo = {
        text = "Repository";
        url = "https://github.com/Koromix/rygel/tree/master/src/goupile";
      };
      homepage = {
        text = "Homepage";
        url = "https://goupile.org/en";
      };
      docs = {
        text = "User Documentation";
        url = "https://goupile.org/en/main";
      };
    };
  };

  nixos.modules.services = {
    goupile = {
      name = "Goupile";
      module = ./services/goupile/module.nix;
      examples.basic = {
        module = ./services/goupile/examples/basic.nix;
        description = ''
          TODO example description
        '';
        tests.basic.module = import ./services/goupile/tests/basic.nix args;
      };
      links = {
        build = {
          text = "Build from source";
          url = "https://goupile.org/en/build";
        };
        test = {
          text = "Test instructions";
          url = "https://goupile.org/en/setup";
        };
      };
    };
  };

  nixos.demo.shell = {
    module = ./demo/module.nix;
    module-demo = ./demo/module-demo.nix;
    usage-instructions = [
      {
        instruction = ''
          Run the vm
        '';
      }
      {
        instruction = ''
          Visit [http://127.0.0.1:8080](http://127.0.0.1:8080) in your browser
        '';
      }
    ];
    tests.demo.module = import ./services/goupile/tests/basic.nix args;
  };
}
