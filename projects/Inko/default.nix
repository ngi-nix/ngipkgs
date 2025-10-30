{
  lib,
  pkgs,
  sources,
  ...
}@args:

{
  metadata = {
    summary = "Programming language with deterministic automatic memory management";
    subgrants.Entrust = [
      "Inko"
    ];
  };

  nixos.modules.programs = {
    inko = {
      module = ./module.nix;
      examples.basic = {
        module = ./example.nix;
        description = "";
        tests.basic.module = null;
      };
    };
  };
}
