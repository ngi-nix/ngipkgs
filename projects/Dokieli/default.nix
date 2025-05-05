{
  lib,
  pkgs,
  sources,
}@args:

{
  metadata = {
    summary = "Clientside editor for decentralised article publishing, annotations and social interactions";
    subgrants = [
      "Dokieli"
    ];
  };

  nixos.programs = {
    dokieli = {
      module = ./module.nix;
      examples.basic = {
        module = ./example.nix;
        description = "";
        tests.basic = null;
      };
    };
  };
}
