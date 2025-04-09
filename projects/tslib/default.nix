{
  lib,
  pkgs,
  sources,
}@args:

{
  metadata = {
    summary = "Better configuration and callibration of touchscreen devices";
    subgrants = [
      "tslib"
    ];
  };

  nixos.modules.programs = {
    tslib = {
      module = ./module.nix;
      examples.basic = {
        module = ./example.nix;
        description = "";
        tests.basic = null;
      };
    };
  };
}
