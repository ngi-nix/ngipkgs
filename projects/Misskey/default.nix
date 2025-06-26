{
  lib,
  pkgs,
  sources,
  ...
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
      module = lib.moduleLocFromOptionString "services.misskey";
      examples.basic = {
        module = ./services/misskey/examples/basic.nix;
        description = "";
        tests.misskey = pkgs.nixosTests.misskey;
      };
    };
  };
}
