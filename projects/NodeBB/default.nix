{
  lib,
  pkgs,
  sources,
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

  nixos.modules.services = {
    nodebb = {
      name = "NodeBB";
      module = ./services/nodebb/module.nix;
      examples.basic = {
        module = ./services/nodebb/examples/basic.nix;
        description = "";
        tests.basic = null;
      };
    };
  };
}
