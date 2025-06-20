{
  lib,
  pkgs,
  sources,
  ...
}@args:

{
  metadata = {
    summary = "Portable ActivityPub implementation";
    subgrants = [
      "Seppo"
    ];
    links = {
      install = {
        text = "Installation Instructions";
        url = "https://seppo.mro.name/en/support/#installation";
      };
      source = {
        text = "Codeberg repository";
        url = "https://codeberg.org/seppo/seppo#seppo";
      };
    };
  };

  nixos.modules.programs.seppo = null;
  nixos.modules.services.seppo = null;
}
