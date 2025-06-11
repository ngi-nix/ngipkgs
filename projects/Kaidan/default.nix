{
  lib,
  pkgs,
  sources,
}@args:

{
  metadata = {
    summary = "Cross-platform chat client for the XMPP protocol";
    subgrants = [
      "Kaidan"
      "Kaidan-Groups"
      "Kaidan-AV"
      "Kaidan-Auth"
      "Kaidan-Mediasharing"
      "Kaidan-MUC"
    ];
    links = {
      install = {
        text = "Build Kaidan from source";
        url = "https://invent.kde.org/network/kaidan/-/wikis/building/linux-debian-based";
      };
      source = {
        text = "Git repository";
        url = "https://invent.kde.org/network/kaidan";
      };
    };
  };

  nixos.modules.programs.kaidan = null;
  nixos.modules.services.kaidan = null;
}
