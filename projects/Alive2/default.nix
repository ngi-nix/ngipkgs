{
  lib,
  pkgs,
  sources,
  ...
}@args:
{
  metadata = {
    summary = "Translation validation for LLVM";
    subgrants = [
      "Alive2"
    ];
  };

  nixos.modules.programs.alive2 = {
    module = ./module.nix;
    examples.basic = {
      module = ./example.nix;
      description = "";
      tests.basic.module = import ./test.nix args;
      # https://github.com/AliveToolkit/alive2#running-the-standalone-translation-validation-tool-alive-tv
      tests.translation.module = null;
    };
  };
}
