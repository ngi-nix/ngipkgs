{
  lib,
  pkgs,
  sources,
  ...
}@args:

{
  metadata = {
    summary = "Misskey is a decentralized and open source microblogging platform";
    subgrants.Review = [
      "Misskey"
    ];
  };

  nixos.modules.services = {
    misskey = {
      name = "Misskey";
      # Revert when this is merged and propagated:
      # https://github.com/NixOS/nixpkgs/pull/477674
      module =
        { config, ... }:
        let
          cfg = config.services.misskey;
        in
        {
          imports = [ (lib.moduleLocFromOptionString "services.misskey") ];
          config.systemd.services.misskey.preStart = lib.optionalString cfg.enable ''
            install -m 700 ${
              (pkgs.formats.json { }).generate "misskey-config.json" cfg.settings
            } /run/misskey/default.json
          '';
        };
      examples.basic = {
        module = ./services/misskey/examples/basic.nix;
        description = "";
        tests.misskey.module = import ./services/misskey/test.nix args;
      };
    };
  };
}
