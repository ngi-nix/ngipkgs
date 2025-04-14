{
  lib,
  pkgs,
  sources,
}@args:

{
  metadata = {
    summary = "Canaille is a zero-knowledge opinionated identity server.";
    subgrants = [
      "Canaille"
    ];
  };

  nixos.modules.services = {
    canaille = {
      name = "Canaille";
      module = "${sources.inputs.nixpkgs}/nixos/modules/services/security/canaille.nix";
      examples.basic = {
        module = ./services/Canaille/examples/basic.nix;
        description = "";
        tests.canaille = "${sources.inputs.nixpkgs}/nixos/tests/canaille.nix";
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
