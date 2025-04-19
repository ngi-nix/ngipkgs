{
  lib,
  pkgs,
  sources,
}@args:

{
  metadata = {
    summary = "Seppo is a portable ActivityPub implementation for hosting microblogs";
    subgrants = [
      "Seppo"
    ];
    links = {
      website = {
        text = "#Seppo!";
        url = "https://seppo.social";
      };
      source = {
        text = "Seppo source code";
        url = "https://codeberg.org/seppo/seppo";
      };
    };
  };

  # TODO: add Seppo service definition (https://github.com/ngi-nix/ngipkgs/issues/320)
  nixos.modules.services.seppo = null;
}
