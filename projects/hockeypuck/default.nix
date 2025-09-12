{
  lib,
  pkgs,
  sources,
  ...
}@args:

{
  metadata = {
    summary = "OpenPGP keyserver";
    subgrants = [
      "Hockeypuck"
    ];
  };

  nixos.modules.services = {
    hockeypuck = {
      name = "hockeypuck";
      module = lib.moduleLocFromOptionString "services.hockeypuck";
      examples."Enable hockeypuck" = {
        module = ./services/hockeypuck/examples/basic.nix;
        tests.basic.module = pkgs.nixosTests.hockeypuck;
      };
    };
  };

  nixos.demo.vm = {
    module = ./services/hockeypuck/examples/basic.nix;
    description = "Demo for hockeypuck";
    tests.basic.module = pkgs.nixosTests.hockeypuck;
  };
}
