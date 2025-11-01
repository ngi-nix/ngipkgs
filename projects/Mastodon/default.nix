{
  lib,
  pkgs,
  sources,
  ...
}@args:
{
  metadata = {
    summary = ''
      Free and open-source software platform for decentralized social networking.
    '';
    subgrants = {
      Commons = [
        "Mastodon-for-institutions"
      ];
      Entrust = [
        "Mastodon-Quoting"
      ];
      Review = [
        "Mastodon"
      ];
    };
  };
  nixos = {
    modules.services.mastodon = {
      module = lib.moduleLocFromOptionString "services.mastodon";
      examples.basic.module = null;
    };
    tests.standard.module = pkgs.nixosTests.mastodon.standard;
    tests.remote-databases.module = pkgs.nixosTests.mastodon.remote-databases;
  };
}
