{
  lib,
  pkgs,
  sources,
}@args:

{
  metadata = {
    summary = "GNUnet is GNU's framework for secure peer-to-peer networking";
    subgrants = [
      "gnunet"
      "GNUnet-CONG"
      "GNUnet-Messenger"
      "GNUnet-Android"
      "GNUnet-L2"
      "gnunet-test"
      "ProbabilisticNAT"
    ];
  };

  nixos.modules.services = {
    gnunet = {
      name = "gnunet";
      module = "${sources.inputs.nixpkgs}/nixos/modules/services/networking/gnunet.nix";
      examples.basic = {
        module = ./services/gnunet/examples/basic.nix;
        description = "";
        tests.basic = import ./services/gnunet/tests/basic.nix args;
      };
      links = {
        build = {
          text = "Build from source";
          url = "https://docs.gnunet.org/latest/installing.html";
        };
        manual = {
          text = "User Manual";
          url = "https://docs.gnunet.org/latest/users/index.html#user-manual";
        };
      };
    };
  };
}
