{
  lib,
  pkgs,
  sources,
  ...
}@args:

{
  metadata = {
    summary = "Open source web-based document editor";
    subgrants.Core = [
      "Wax"
    ];
    links = {
      website = {
        text = "Website";
        url = "https://wax.is";
      };
      docs = null;
      source = {
        text = "Source repository";
        url = "https://github.com/Wax-Platform/Wax";
      };
    };
  };

  nixos.modules.programs.wax.module = null;
  nixos.modules.services.wax.module = null;
}
