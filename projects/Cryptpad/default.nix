{
  pkgs,
  lib,
  sources,
  ...
}@args:
{
  metadata = {
    summary = ''
      Collaborative office suite that is end-to-end encrypted and open-source.
    '';
    subgrants = {
      Entrust = [
        "CryptPad-Blueprints"
      ];
      Review = [
        "Cryptpad"
        "CryptPad-Auth"
        "Cryptpad-Directory"
        "Cryptpad-Communities"
        "CryptPad-QA"
        "CryptPad-WCAG"
        "CryptPadForms"
      ];
    };
  };
  nixos.modules.services = {
    cryptpad = {
      name = "cryptpad";
      module = ./module.nix;
      examples."Enable Cryptpad" = {
        module = ./demo.nix;
        tests.basic.module = pkgs.nixosTests.cryptpad;
      };
      links = {
        admin-guide = {
          text = "Administration guide";
          url = "https://docs.cryptpad.org/en/admin_guide/index.html";
        };
      };
    };
  };
  nixos.demo.vm = {
    module = ./demo.nix;
    description = "Deployment for demo purposes";
    tests.demo.module = ./demo-test.nix;
  };
}
