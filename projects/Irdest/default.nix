{
  lib,
  pkgs,
  sources,
  ...
}@args:

{
  metadata = {
    summary = "Modular decentralized peer-to-peer packet router and associated tools";
    subgrants = {
      Review = [ "Irdest" ];
      Core = [ "Irdest-Proxy" ];
      Entrust = [
        "Irdest-OpenWRT-BLE"
        "Irdest-Spec"
      ];
    };
    links = {
      documentation = {
        text = "Documentation";
        url = "https://codeberg.org/irdest/irdest/src/branch/main/docs/user/src/SUMMARY.md";
      };
      website = {
        text = "Website";
        url = "https://irde.st";
      };
    };
  };

  binary.irdest-lora-firmware.data = pkgs.irdest-lora-firmware;

  nixos.modules = {
    # https://github.com/ngi-nix/ngipkgs/issues/1514
    programs.irdest-mblog.module = null;
    services = {
      ratmand = {
        module = ./services/ratmand/module.nix;
        examples.basic-ratmand = {
          module = ./services/ratmand/examples/basic.nix;
          description = "Basic ratmand configuration";
          tests = {
            ratmand-config.module = ./services/ratmand/tests/config.nix;
            peer-communication.module = ./services/ratmand/tests/peer-communication.nix;
            peer-communication.problem.broken.reason = ''
              Test fails and is not reproducible, locally.

              https://buildbot.ngi.nixos.org/#/builders/1257/builds/60
            '';
          };
        };
      };
      # https://github.com/ngi-nix/ngipkgs/issues/1511
      irdest-proxy.module = null;
      # https://github.com/ngi-nix/ngipkgs/issues/1513
      irdest-echo.module = null;
    };
  };
  nixos.demo.vm = {
    module = ./services/ratmand/examples/basic.nix;
    module-demo = ./demo/module-demo.nix;
    usage-instructions = [
      {
        instruction = "`ratman-tools` are available in the shell.";
      }
      {
        instruction = "The ratmand dashboard is available at http://localhost:5850.";
      }
    ];
    tests.demo-basic.module = ./demo/tests/basic.nix;
    tests.demo-basic.problem.broken.reason = ''
      This has been failing in CI for a while and the failure is not
      reproducible, locally.

      https://buildbot.ngi.nixos.org/#/builders/1255/builds/79
    '';
  };
}
