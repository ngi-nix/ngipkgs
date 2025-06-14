{
  lib,
  pkgs,
  sources,
}@args:

{
  metadata = {
    summary = "Holo is a suite of routing protocols designed to address the needs of modern networks";
    subgrants = [
      "HoloRouting"
    ];
  };

  nixos.modules.programs = {
    holo = {
      name = "holo";
      # if a project has `packages`, add them inside the `module.nix` file
      module = ./programs/holo/module.nix;
      examples.basic = {
        module = ./programs/holo/examples/basic.nix;
        description = "Enable the holo program";
        tests.basic = import ./programs/holo/tests/basic.nix args;
      };
    };
  };

  # TODO: add service module
  nixos.modules.services.holo-daemon = null;
}
