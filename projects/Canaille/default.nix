{
  lib,
  pkgs,
  sources,
  ...
}@args:

{
  metadata = {
    summary = "Canaille is a zero-knowledge opinionated identity server.";
    subgrants.Entrust = [
      "Canaille"
    ];
  };

  nixos.modules.services = {
    canaille = {
      name = "Canaille";
      module = lib.moduleLocFromOptionString "services.canaille";
      examples.basic = {
        module = ./services/Canaille/examples/basic.nix;
        description = "";
        tests.canaille = {
          module = pkgs.nixosTests.canaille;
        };
      };
      links = {
        build = {
          text = "Build from source";
          url = "https://github.com/NixOS/nixpkgs/blob/1750f3c1c89488e2ffdd47cab9d05454dddfb734/pkgs/by-name/ca/canaille/package.nix#L134";
        };
        test = {
          text = "Usage example";
          url = "https://gitlab.com/yaal/canaille/#locally";
        };
      };
    };
  };
}
