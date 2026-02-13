{
  lib,
  pkgs,
  sources,
  ...
}@args:

{
  metadata = {
    summary = "Bcachefs is a modern filesystem for Linux designed with a focus on reliability, robustness, and performance.";
    subgrants = {
      Commons = [ "bcachefs-crypto-API" ];
      Entrust = [ "bcachefs" ];
    };
    links = {
      docs = {
        text = "User Manual";
        url = "https://bcachefs.org/bcachefs-principles-of-operation.pdf";
      };
      homepage = {
        text = "Homepage";
        url = "https://bcachefs.org";
      };
      repo = {
        text = "Source Repository";
        url = "https://github.com/koverstreet/bcachefs";
      };
    };
  };

  nixos.tests.bcachefs.module = pkgs.nixosTests.bcachefs;
}
