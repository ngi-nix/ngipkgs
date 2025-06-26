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

  nixos.modules.programs = {
    taler = {
      module = ./program.nix;
      examples.backup = {
        module = ./examples/backup.nix;
        description = "Backup with anastasis";
        tests.anastasis = import ../../pkgs/by-name/anastasis/test.nix {
          inherit lib pkgs;
          inherit (pkgs) nixosTest anastasis;
        };
      };
    };
  };

  nixos.modules.services = {
    taler = {
      module = lib.moduleLocFromOptionString "services.taler";
      examples.basic = {
        # See https://github.com/NixOS/nixpkgs/blob/master/nixos/tests/taler/common/nodes.nix
        module = ./examples/basic/default.nix;
        description = "Basic GNU Taler configuration";
        tests.basic = pkgs.nixosTests.taler.basic;
      };
    };
  };
}
