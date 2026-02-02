{
  lib,
  pkgs,
  sources,
  ...
}@args:

{
  metadata = {
    summary = "Advanced electronic payment system for privacy-preserving payments";
    subgrants = {
      Entrust = [
        "GNUTaler-LocalCurrencies"
        "Taler-iOS-wallet"
      ];
      Review = [
        "GNUTaler"
        "GNUTaler-KYC"
        "MTE" # MirageOS Taler Exchange
      ];
    };
    links = {
      docs = {
        text = "GNU Taler Documentation";
        url = "https://docs.taler.net/";
      };
    };
  };

  nixos.modules.services = {
    taler = {
      module = lib.moduleLocFromOptionString "services.taler";
      examples."Basic GNU Taler configuration" = {
        # See https://github.com/NixOS/nixpkgs/blob/master/nixos/tests/taler/common/nodes.nix
        # TODO: render multi-file examples in the overview
        module = ./examples/basic/default.nix;
        tests.basic.module = pkgs.nixosTests.taler.basic;
      };
      examples."Backup with anastasis" = {
        module = ./examples/backup.nix;
        tests.anastasis.module = ./tests/backup.nix;
        tests.anastasis.problem.broken.reason = ''
          Latest version available of anastasis isn't compatible with the
          latest GNUnet API.

          https://buildbot.ngi.nixos.org/#/builders/10/builds/3519
        '';
      };
    };
  };
}
