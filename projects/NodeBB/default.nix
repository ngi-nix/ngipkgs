{
  lib,
  pkgs,
  sources,
  ...
}@args:

{
  metadata = {
    summary = "Community forum software";
    subgrants = [
      "NodeBB"
    ];
    links = {
      website = {
        text = "Website";
        url = "https://nodebb.org/";
      };
      docs = {
        text = "Documentation";
        url = "https://docs.nodebb.org/";
      };
      src = {
        text = "Source repository";
        url = "https://github.com/NodeBB/NodeBB";
      };
    };
  };

  nixos = {
    modules.services = {
      nodebb = {
        name = "NodeBB";
        module = ./services/nodebb/module.nix;
        examples = {
          "Enable NodeBB with postgresql" = {
            module = ./services/nodebb/examples/postgresql.nix;
            tests.postgresql.module = import ./services/nodebb/tests/postgresql.nix args;
          };
          "Enable NodeBB with redis" = {
            module = ./services/nodebb/examples/redis.nix;
            tests.redis.module = import ./services/nodebb/tests/redis.nix args;
          };
        };
      };
    };
    demo.vm = {
      module = ./services/nodebb/examples/postgresql.nix;
      module-demo = ./module-demo.nix;
      description = "Deployment for demo purposes";
      tests.postgresql.module = import ./services/nodebb/tests/postgresql.nix args;
    };
  };
}
