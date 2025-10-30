{
  lib,
  pkgs,
  sources,
  ...
}@args:

{
  metadata = {
    summary = "Clientside editor for decentralised article publishing, annotations and social interactions";
    subgrants.Entrust = [
      "Dokieli"
    ];
  };

  nixos.modules.programs = {
    dokieli = {
      module = ./module.nix;
      examples.basic = {
        module = ./example.nix;
        description = "";
        tests.basic.module = null;
      };
    };
  };
}
