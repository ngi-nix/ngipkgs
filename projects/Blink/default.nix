{
  lib,
  pkgs,
  sources,
  ...
}@args:
{
  metadata = {
    summary = ''
      Blink is a mature open source real-time communication application that can be used on different operating systems,
      based on the IETF SIP standard. It offers audio, video, instant messaging and desktop sharing. It supports
      end-to-end asynchronous messaging and end-to-end encryption which works both online (OTR) and offline (OpenPGP).
    '';
    subgrants = [
      "BlinkRELOAD"
      "Blink-OTR-OpenPGP"
      "Blink-Windows"
    ];
  };

  nixos = {
    modules.programs.blink = {
      module = ./module.nix;
      examples."Enable Blink" = {
        module = ./examples/basic.nix;
        tests.basic.module = import ./tests/basic.nix args;
      };
    };
  };
}
