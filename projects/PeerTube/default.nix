{
  lib,
  pkgs,
  sources,
  ...
}@args:

{
  metadata = {
    summary = "A decentralised streaming video platform";
    subgrants = [
      "PeerTube"
      "PeerTubeSearch"
      "Peertube-Transcode"
      "Peertube-Livechat"
      "PeerTubeDesktop"
      "PeerTube-mobile"
    ];
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
            tests.basic-cli.module = import ./programs/peertube-cli/tests/basic.nix args;
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
          examples.basic = {
            module = ./services/peertube/examples/basic.nix;
            description = "Basic server configuration";
            tests.peertube-plugins.module = import ./services/peertube/tests/peertube-plugins.nix args;
            tests.peertube-plugin-livechat.module = import ./services/peertube/tests/peertube-plugin-livechat.nix args;
          };
        };
      };
    };
    demo.vm = {
      module = ./services/peertube/examples/basic.nix;
      description = ''
        PeerTube service demo.

        The web UI is available at http://localhost:9000/.

        You can log in with:
          - username: root
          - password: changeme
      '';
      tests.peertube-plugins.module = import ./services/peertube/tests/peertube-plugins.nix args;
      tests.peertube-plugin-livechat.module = import ./services/peertube/tests/peertube-plugin-livechat.nix args;
    };
  };
}
