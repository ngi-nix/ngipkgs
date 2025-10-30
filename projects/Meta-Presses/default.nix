{
  lib,
  pkgs,
  sources,
  ...
}@args:

{
  metadata = {
    summary = "Decentralized search engine & automatized press reviews";
    subgrants = {
      Entrust = [
        "Meta-Press.es-modularity"
      ];
      Review = [
        "Meta-Presses"
        "Meta-Presses-scaleup"
      ];
    };
  };

  nixos.modules.programs = {
    meta-presses = {
      module = ./module.nix;
      examples.basic = {
        module = ./example.nix;
        description = "";
        tests.basic.module = null;
      };
    };
  };
}
