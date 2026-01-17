{
  lib,
  pkgs,
  sources,
  ...
}@args:

{
  metadata = {
    summary = "Measure and visualize Wi-Fi coverage";
    subgrants.Core = [
      "0WM"
    ];
    links = {
      repo = {
        text = "Source repository";
        url = "https://github.com/lab0-cc";
      };
      homepage = {
        text = "Homepage";
        url = "https://0wm.lab0.cc";
      };
      docs = null;
    };
  };

  nixos.modules.programs = {
    zwm-client = {
      module = ./programs/0wm-client/module.nix;
      examples."Enable 0WM client" = {
        module = ./programs/0wm-client/examples/basic.nix;
        tests.basic.module = ./tests/basic.nix;
      };
    };
  };

  nixos.modules.services = {
    zwm-server = {
      module = ./services/0wm-server/module.nix;
      examples."Enable 0WM server" = {
        module = ./services/0wm-server/examples/basic.nix;
        tests.basic.module = ./tests/basic.nix;
      };
    };
  };

  nixos.demo.vm = {
    module = ./demo/module.nix;
    module-demo = ./demo/module-demo.nix;
    usage-instructions = [
      {
        instruction = ''
          Click on the bottom left menu, `Network`, and open the `Chromium` browser
        '';
      }
      {
        instruction = ''
          Open a terminal and start the client, OpMode and mock access point programs:

          ```
          $ 0wm-client &
          $ 0wm-opmode &
          $ 0wm-ap-mock &
          ```
        '';
      }
      {
        instruction = ''
          Visit [http://127.0.0.1:8002](http://127.0.0.1:8002) in your browser
        '';
      }
      {
        instruction = ''
          Press the `Click here to start` button and give it location permissions, when asked.

          If the icons on the left are not green, you may have to restart the page for the permissions change to take effect.
        '';
      }
      {
        instruction = ''
          Press the `SCAN` button, on the right, which will scan the mock access point.
        '';
      }
      {
        instruction = ''
          If the scan was successful, the following will be printed in the terminal:

          ```
          "GET /cgi-bin/scan/radio0 HTTP/1.1" 200 -
          "GET /cgi-bin/scan/radio1 HTTP/1.1" 200 -
          ```
        '';
      }
    ];
    tests.demo.module = ./tests/basic.nix;
  };
}
