{
  lib,
  pkgs,
  sources,
}@args:
{
  metadata = {
    subgrants = [
      "Alive2"
    ];
  };

  nixos.programs.alive2 = {
    module = ./module.nix;
    examples.basic = {
      module = ./example.nix;
      description = "";
      tests.basic = import ./test.nix args;
      # https://github.com/AliveToolkit/alive2#running-the-standalone-translation-validation-tool-alive-tv
      tests.translation = null;
    };
  };
}
