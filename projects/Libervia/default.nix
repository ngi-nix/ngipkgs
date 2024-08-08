{
  pkgs,
  lib,
  sources,
} @ args: {
  packages = {inherit (pkgs) brython doubleratchet helium libervia-backend libervia-media libervia-templates libervia-web libxeddsa oldmemo omemo sat-tmp twomemo urwid-satext wokkel x3dh xeddsa;};
  nixos = {
    modules.programs.libervia = ./module.nix;
    tests.libervia = import ./test.nix args;
    examples = rec {
      base = {
        description = "Enables the use of Libervia.";
        path = ./examples/base.nix;
      };
    };
  };
}
