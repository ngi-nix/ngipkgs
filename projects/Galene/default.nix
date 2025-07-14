{
  lib,
  pkgs,
  sources,
  ...
}@args:
{
  metadata = {
    summary = "Galene is a self-hosted video conferencing server. It features advanced networking and video algorithms and automatic subtitling.";
    subgrants = [
      "Galene"
    ];
  };

  nixos.modules.services = {
    galene = {
      name = "galene";
      module = ./module.nix;
      examples."Enable Galene" = {
        module = ./example.nix;
        tests.basic.module = pkgs.nixosTests.galene.basic;
        tests.file-transfer.module = pkgs.nixosTests.galene.file-transfer;
        tests.stream.module = pkgs.nixosTests.galene.stream;
      };
      links = {
        build = {
          text = "Galene Installation";
          url = "https://galene.org/INSTALL.html";
        };
        test = {
          text = "Usage Instructions";
          url = "https://galene.org/README.html";
        };
      };
    };
  };
  nixos.demo.vm = {
    module = ./example.nix;
    tests.basic.module = pkgs.nixosTests.galene.basic;
  };
}
