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
    subgrants = [
      "Cryptpad"
      "CryptPad-Auth"
      "Cryptpad-Directory"
      "CryptPad-Blueprints"
      "Cryptpad-Communities"
      "CryptPad-QA"
      "CryptPad-WCAG"
      "CryptPadForms"
    ];
  };
  nixos.modules.services = {
    cryptpad = {
      name = "cryptpad";
      module = ./module.nix;
      links = {
        admin-guide = {
          text = "Administration guide";
          url = "https://docs.cryptpad.org/en/admin_guide/index.html";
        };
      };
    };
  };
  nixos.tests.basic.module = pkgs.nixosTests.cryptpad;
  nixos.demo.vm = {
    module = ./demo.nix;
    description = "Deployment for demo purposes";
    tests.demo.module = import ./demo-test.nix args;
  };
}
