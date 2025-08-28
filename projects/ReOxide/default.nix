{
  lib,
  pkgs,
  sources,
  ...
}@args:

{
  metadata = {
    summary = "Plugin System for the Ghidra Decompiler";
    subgrants.Entrust = [
      "ReOxide"
    ];
    links = {
      Website = {
        text = "Website";
        url = "https://reoxide.eu/";
      };
      source = {
        text = "Source repository";
        url = "https://codeberg.org/ReOxide";
      };
      documentation = {
        text = "Documentation";
        url = "https://reoxide.eu/guide/getting-started";
      };
    };
  };

  nixos.modules.programs.reoxide.module = null;
  nixos.modules.services.reoxide.module = null;
}
