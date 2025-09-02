{
  lib,
  pkgs,
  sources,
  ...
}@args:

{
  metadata = {
    summary = "Oblivious Pseudo-random Functions (OPRFs) and Threshold constructions implementations";
    subgrants = [
      "OpaqueSphinxServer"
      "OpaqueStore-Sphinx2.0"
      "ThresholdOPRF"
    ];
  };

  nixos.modules.programs = {
    ThresholdOPRF = {
      name = "ThresholdOPRF";
      module = ./programs/ThresholdOPRF/module.nix;
      examples."Enable ThresholdOPRF" = {
        module = ./programs/ThresholdOPRF/examples/basic.nix;
        description = "";
        tests.basic.module = null;
      };
    };
  };

  # pwdsphinx needs a module
  nixos.modules.services.ThresholdOPRF.module = null;
}
