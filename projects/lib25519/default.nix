{
  lib,
  pkgs,
  sources,
}@args:

{
  metadata = {
    summary = "Microlibrary for the X25519 encryption system and the Ed25519 signature system";
    subgrants = [
      "lib25519"
      "lib25519-ARM"
      "lib25519-ARM64"
    ];
  };

  nixos.programs = {
    # TODO: figure out a better representation for this since it's a library
    lib25519 = {
      module = ./module.nix;
      examples.basic = {
        module = ./example.nix;
        description = "";
        tests.basic = null;
      };
    };
  };
}
