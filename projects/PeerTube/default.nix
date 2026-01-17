{
  lib,
  pkgs,
  sources,
  ...
}@args:

{
  metadata = {
    summary = "A decentralised streaming video platform";
    subgrants = {
      Entrust = [
        "Peertube-Transcode"
        "Peertube-Livechat"
        "PeerTube-mobile"
      ];
      Review = [
        "PeerTube"
        "PeerTubeSearch"
        "PeerTubeDesktop"
      ];
    };
    links = {
      website = {
        text = "Website";
        url = "https://joinpeertube.org/";
      };
      docs = {
        text = "Documentation";
        url = "https://docs.joinpeertube.org/";
      };
    };
  };

  nixos = {
    modules = {
      programs = {
        peertube-cli = {
          module = ./programs/peertube-cli/module.nix;
          examples.basic-cli = {
            module = ./programs/peertube-cli/examples/basic.nix;
            description = ''
              Enable peertube-cli, a tool for remotely managing PeerTube instances
            '';
            tests.basic-cli.module = ./programs/peertube-cli/tests/basic.nix;
          };
          links = {
            docs = {
              text = "Documentation";
              url = "https://docs.joinpeertube.org/maintain/tools#remote-peertube-cli";
            };
          };
        };
      };

      services = {
        peertube = {
          module = ./services/peertube/module.nix;
          examples.basic-server = {
            module = ./services/peertube/examples/basic.nix;
            description = "Basic server configuration";
            tests.peertube-plugins.module = ./services/peertube/tests/peertube-plugins.nix;
            tests.peertube-plugin-livechat.module = ./services/peertube/tests/peertube-plugin-livechat.nix;
          };
        };
        peertube-runner = {
          module = lib.moduleLocFromOptionString "services.peertube-runner";
          examples.basic-runner = {
            module = ./services/peertube-runner/examples/basic.nix;
            description = "Basic peertube-runner configuration";
            tests.basic-runner.module = ./services/peertube-runner/tests/basic.nix;
            tests.basic-runner.problem.broken.reason = ''
              Dependency failure: `python3Packages.torch-audiomentations`

              Fixed in https://github.com/NixOS/nixpkgs/pull/457825
            '';
          };
          links = {
            docs = {
              text = "Documentation";
              url = "https://docs.joinpeertube.org/admin/remote-runners";
            };
          };
        };
      };
    };
    demo.vm = {
      module = ./services/peertube/examples/basic.nix;
      usage-instructions = [
        {
          instruction = ''
            The web UI is available at http://localhost:9000/.
          '';
        }
        {
          instruction = ''
            You can log in with:
            - username: `root`
            - password: `changeme`
          '';
        }
      ];
      tests.peertube-plugins.module = ./services/peertube/tests/peertube-plugins.nix;
      tests.peertube-plugin-livechat.module = ./services/peertube/tests/peertube-plugin-livechat.nix;
    };
  };
}
