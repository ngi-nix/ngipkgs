{
  lib,
  pkgs,
  sources,
  ...
}@args:
{
  metadata = {
    summary = "Translation validation for LLVM";
    subgrants.Core = [
      "Alive2"
    ];
    links = {
      repo = {
        text = "Source repository";
        url = "https://github.com/AliveToolkit/alive2";
      };
      homepage = null;
      docs = null;
    };
  };

  nixos.modules.programs.alive2 = {
    module = ./module.nix;
    examples.basic = {
      module = ./example.nix;
      description = "";
      tests.basic.module = ./test.nix;
      # https://github.com/AliveToolkit/alive2#running-the-standalone-translation-validation-tool-alive-tv
      tests.translation.module = null;
    };
  };
}
