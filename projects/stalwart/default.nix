{
  lib,
  pkgs,
  sources,
  ...
}@args:

{
  metadata = {
    summary = "Integrated solution for email, calendaring and file management";
    subgrants = [
      "Stalwart"
      "Stalwart-Collaboration"
    ];
  };

  nixos.modules.services = {
    stalwart-mail = {
      name = "Stalwart Mail Server";
      module = lib.moduleLocFromOptionString "services.stalwart-mail";
      examples."Enable Stalwart Mail Server" = {
        module = "${sources.inputs.nixpkgs}/nixos/tests/stalwart/stalwart-mail-config.nix";
        description = ''
          Basic configuration for stalwart mail server.
        '';
        tests.basic.module = pkgs.nixosTests.stalwart-mail;
      };
    };
  };
}
