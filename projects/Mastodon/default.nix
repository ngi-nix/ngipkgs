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
    tests = {
      inherit (pkgs.nixosTests.mastodon)
        standard
        remote-databases
        ;
    };
  };
}
