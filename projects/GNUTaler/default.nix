{
  lib,
  pkgs,
  sources,
  ...
}@args:

{
  metadata = {
    summary = "Advanced electronic payment system for privacy-preserving payments";
    subgrants = [
      # Review
      "GNUTaler"
      "GNUTaler-KYC"

      # Entrust
      "GNUTaler-LocalCurrencies"
      "Taler-iOS-wallet"
    ];
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
        tests.basic.problem.broken.reason = ''
          Libeufin dependencies need to be updated

          https://github.com/NixOS/nixpkgs/pull/425714
        '';
      };
      examples."Backup with anastasis" = {
        module = ./examples/backup.nix;
        tests.anastasis.module = import ../../pkgs/by-name/anastasis/test.nix {
          inherit lib pkgs;
          inherit (pkgs) nixosTest anastasis;
        };
      };
    };
  };
}
