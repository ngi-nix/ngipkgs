{
  lib,
  pkgs,
  sources,
}@args:

{
  metadata = {
    summary = "Misskey is a decentralized and open source microblogging platform";
    subgrants = [
      "Misskey"
    ];
  };

  nixos.modules.services = {
    misskey = {
      name = "Misskey";
      module = "${sources.inputs.nixpkgs}/nixos/modules/services/web-apps/misskey.nix";
      examples.basic = {
        module = ./services/misskey/examples/basic.nix;
        description = "";
        tests.misskey = "${sources.inputs.nixpkgs}/nixos/tests/misskey.nix";
      };
    };
  };
}
