{
  lib,
  pkgs,
  sources,
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
        # FIX: enable after separating nixpkgs invocation
        # https://github.com/ngi-nix/ngipkgs/pull/861
        # tests.anastasis = import ../../pkgs/by-name/anastasis/test.nix {
        #   inherit lib pkgs;
        #   inherit (pkgs) nixosTest anastasis;
        # };
        tests.anastasis = null;
      };
    };
  };

  nixos.modules.services = {
    taler = {
      module = "${sources.inputs.nixpkgs}/nixos/modules/services/finance/taler/module.nix";
      examples.basic = {
        # See https://github.com/NixOS/nixpkgs/blob/master/nixos/tests/taler/common/nodes.nix
        module = ./examples/basic/default.nix;
        description = "Basic GNU Taler configuration";
        # FIX: currently broken in nixpkgs
        # tests.basic = "${sources.inputs.nixpkgs}/nixos/tests/taler/tests/basic.nix";
        tests.basic = null;
      };
    };
  };
}
