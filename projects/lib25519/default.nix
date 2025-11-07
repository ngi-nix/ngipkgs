{
  lib,
  pkgs,
  sources,
  ...
}@args:

{
  metadata = {
    summary = "Microlibrary for the X25519 encryption system and the Ed25519 signature system";
    subgrants = {
      Core = [
        "lib25519-ARM64"
      ];
      Entrust = [
        "lib25519-ARM"
      ];
      Review = [
        "lib25519"
      ];
    };
  };

  nixos.modules.programs = {
    # TODO: figure out a better representation for this since it's a library
    lib25519 = {
      module = ./module.nix;
      examples.basic = {
        module = ./example.nix;
        description = "";
        tests.basic.module = null;
      };
    };
  };
}
