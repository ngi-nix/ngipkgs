{
  lib,
  pkgs,
  sources,
  ...
}@args:

{
  metadata = {
    summary = "GNUnet is GNU's framework for secure peer-to-peer networking";
    subgrants = {
      Commons = [
        "libgnunetutil"
      ];
      Core = [
        "GNUnet-Android"
      ];
      Entrust = [
        "GNUnet-CONG"
      ];
      Review = [
        "GNS"
        "GNUnet-L2"
        "GNUnet-Messenger"
        "gnunet"
        "gnunet-test"
        "ProbabilisticNAT"
        "R5N-DHT"
      ];
    };
  };

  nixos.modules.services = {
    gnunet = {
      name = "gnunet";
      module = lib.moduleLocFromOptionString "services.gnunet";
      examples.basic = {
        module = ./services/gnunet/examples/basic.nix;
        description = "";
        tests.basic.module = ./services/gnunet/tests/basic.nix;
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
