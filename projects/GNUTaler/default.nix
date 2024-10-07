{
  pkgs,
  sources,
  ...
} @ args: {
  packages = {
    inherit
      (pkgs)
      libeufin
      taler-exchange
      taler-merchant
      taler-wallet-core
      ;
  };
  nixos = {
    examples = {
      base = {
        path = ./example.nix;
        description = "Basic configuration, mainly used for testing purposes.";
      };
    };
    # TODO: enable when https://github.com/NixOS/nixpkgs/pull/332699 is merged
    # tests = import "${sources.inputs.nixpkgs}/nixos/tests/taler" args;
    # modules.services.taler = "${sources.inputs.nixpkgs}/nixos/modules/services/taler/module.nix";
    # modules.services.libeufin = "${sources.inputs.nixpkgs}/nixos/modules/services/libeufin/module.nix";
  };
}
