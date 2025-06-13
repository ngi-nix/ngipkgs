{
  lib,
  pkgs,
  sources,
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

  nixos.modules = {
    programs = {
      peertube-cli = {
        module = ./programs/peertube-cli/module.nix;
        examples.basic-cli = {
          module = ./programs/peertube-cli/examples/basic.nix;
          description = "CLI configuration";
          tests.basic-cli = import ./programs/peertube-cli/tests/basic.nix args;
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
          description = "Basic configuration mainly used for testing purposes";
          tests.peertube-plugins = import ./services/peertube/tests/peertube-plugins.nix args;
        };
      };
    };
  };
}
