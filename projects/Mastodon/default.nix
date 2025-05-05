{
  lib,
  pkgs,
  sources,
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
      examples.basic = null;
    };
    tests = {
      standard = "${sources.inputs.nixpkgs}/nixos/tests/web-apps/mastodon/standard.nix";
      remote-databases = "${sources.inputs.nixpkgs}/nixos/tests/web-apps/mastodon/remote-databases.nix";
    };
  };
}
