{
  lib,
  pkgs,
  sources,
}@args:

{
  metadata = {
    summary = "EDA tool focused on post logic synthesis";
    subgrants = [
      "Naja"
      "Naja-DNL"
    ];
  };

  nixos.modules.programs = {
    naja = {
      module = ./module.nix;
      examples.basic = {
        module = ./example.nix;
        description = "";
        tests.basic = null;
      };
    };
  };
}
