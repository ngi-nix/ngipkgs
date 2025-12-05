{
  lib,
  pkgs,
  sources,
  ...
}@args:

{
  metadata = {
    summary = "A daemon that scans program outputs for repeated patterns, and takes action";
    subgrants = {
      Core = [ "Reaction" ];
    };
    links = {
      repo = {
        text = "Source repository";
        url = "https://framagit.org/ppom/reaction";
      };
      homepage = {
        text = "Homepage";
        url = "https://reaction.ppom.me";
      };
      docs = {
        text = "Usage examples";
        url = "https://reaction.ppom.me/filters/index.html";
      };
    };
  };

  # TODO exists mainly for examples, demo vm and tests, upstream wants it in nixpkgs directly not ngipkgs
  nixos.modules.services = {
    reaction = {
      name = "Reaction";
      module = lib.moduleLocFromOptionString "services.reaction";
      examples.basic = {
        module = ./examples/basic.nix;
        description = ''
          TODO Usage instructions
        '';
        tests.basic.module = import ./tests/basic.nix args;
      };
    };
  };

  nixos.demo.vm = {
    module = ./demo/module.nix;
    module-demo = ./demo/module-demo.nix;
    usage-instructions = [
      {
        instruction = ''
          Reaction TODO
        '';
      }
      {
        instruction = ''
          TODO attempt login via ssh thrice with wrong passwords and see that you are banned?
        '';
      }
    ];
    tests.demo.module = import ./tests/basic.nix args;
  };
}
