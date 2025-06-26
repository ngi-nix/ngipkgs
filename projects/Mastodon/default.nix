{
  lib,
  pkgs,
  sources,
  ...
}@args:
{
  metadata = {
    summary = ''
      Mastodon is a free and open-source software platform for decentralized social networking.
    '';
    subgrants = [
      "Mastodon"
      "Mastodon-Quoting"
    ];
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
