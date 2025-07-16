{
  lib,
  pkgs,
  sources,
  ...
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
        tests.kaidan.module = import ./programs/kaidan/tests/kaidan.nix args;
        tests.kaidan.problem.broken.reason = ''
          The test hangs for a long time and ultimately fails:

          https://buildbot.ngi.nixos.org/#/builders/947/builds/209/steps/1/logs/stdio

          Investigate why and fix it.
        '';
      };
    };
  };
  nixos.modules.services.kaidan.module = null;
}
