{
  pkgs,
  lib,
  sources,
} @ args: {
  packages = {inherit (pkgs) doubleratchet helium libervia-backend libervia-media libervia-templates libxeddsa oldmemo omemo sat-tmp twomemo urwid-satext wokkel x3dh xeddsa;};
  nixos = {
    modules.programs.libervia = ./module.nix;
    tests.libervia = import ./test.nix args;
    examples = rec {
      base = {
        description = "Enables the use of Libervia's basic clients: CLI & TUI.";
        path = ./examples/base.nix;
      };
      media = {
        description = ''
          ${base.description}

          In addition, https://repos.goffi.org/libervia-media gets downloaded and made available to the code.
          This requires allowing unfree derivations.
        '';
        path = ./examples/unfree.nix;
      };
    };
  };
}
