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

  nixos.modules.programs = {
    kaidan = {
      module = ./programs/kaidan/module.nix;
      examples.basic = {
        module = ./programs/kaidan/examples/basic.nix;
        description = "Kaidan program example";
        # TODO: Write tests
        # Test requires x-server, OCR and maybe an XMPP server
        tests.kaidan = null;
      };
    };
  };
  nixos.modules.services.kaidan = null;
}
