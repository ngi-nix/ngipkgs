{
  lib,
  pkgs,
  sources,
}@args:

{
  metadata = {
    summary = "Open source web search engine";
    subgrants = [
      "Stract"
    ];
  };

  nixos.modules.programs = {
    stract = {
      module = ./module.nix;
      examples.basic = {
        module = ./example.nix;
        description = "";
        tests.basic = null;
      };
    };
  };
}
