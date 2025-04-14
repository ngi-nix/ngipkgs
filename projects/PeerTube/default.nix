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

  nixos.modules.services = {
    peertube = {
      name = "peertube";
      module = ./services/peertube/module.nix;
      examples.basic = {
        module = ./services/peertube/examples/basic.nix;
        description = "Basic configuration mainly used for testing purposes.";
        tests.peertube-plugins = import ./services/peertube/tests/peertube-plugins.nix args;
      };
    };
  };
}
