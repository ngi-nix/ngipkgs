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
    subgrants = {
      Entrust = [
        "Blink-Windows"
      ];
      Review = [
        "BlinkRELOAD"
        "Blink-OTR-OpenPGP"
      ];
    };
    links = {
      homepage = {
        text = "Homepage";
        url = "https://icanblink.com";
      };
      repo = {
        text = "Source repository";
        url = "http://devel.ag-projects.com/repositories/blink-qt";
      };
      docs = null;
    };
  };

  nixos = {
    modules.programs.blink = {
      module = ./module.nix;
      examples."Enable Blink" = {
        module = ./examples/basic.nix;
        tests.basic.module = ./tests/basic.nix;
      };
    };

    demo.shell = {
      usage-instructions = [
        {
          instruction = ''
            Run `blink` to open the application.
          '';
        }
        {
          instruction = ''
            It should either open the application as a window, or add an entry to your desktop's indicator bar.
          '';
        }
      ];
      module = ./examples/basic.nix;
      module-demo = ./module-demo.nix;
      tests.basic.module = ./tests/basic.nix;
    };
  };
}
