{
  lib,
  pkgs,
  sources,
}@args:

{
  metadata = {
    summary = "Decentralized search engine & automatized press reviews";
    subgrants = [
      "Meta-Press.es-modularity"
      "Meta-Presses"
      "Meta-Presses-scaleup"
    ];
  };

  nixos.modules.programs = {
    meta-presses = {
      module = ./module.nix;
      examples.basic = {
        module = ./example.nix;
        description = "";
        tests.basic = null;
      };
    };
  };
}
