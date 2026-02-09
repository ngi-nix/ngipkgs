{
  lib,
  pkgs,
  sources,
  ...
}@args:

{
  metadata = {
    summary = "Integrated solution for email, calendaring and file management";
    subgrants = {
      Core = [
        "Stalwart-Collaboration"
      ];
      Entrust = [
        "Stalwart"
      ];
    };
  };

  nixos.modules.services = {
    stalwart-mail = {
      name = "Stalwart Mail Server";
      module = lib.moduleLocFromOptionString "services.stalwart";
      examples."Enable Stalwart Mail Server" = {
        module = "${sources.inputs.nixpkgs}/nixos/tests/stalwart/stalwart-config.nix";
        description = ''
          Basic configuration for stalwart mail server.
        '';
        tests.basic.module = pkgs.nixosTests.stalwart;
      };
    };
  };
}
