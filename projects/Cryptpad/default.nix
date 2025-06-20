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
      examples.demo = {
        module = ./demo.nix;
        description = "Deployment for demo purposes";
        tests.demo = import ./demo-test.nix args;
      };
      links = {
        admin-guide = {
          text = "Administration guide";
          url = "https://docs.cryptpad.org/en/admin_guide/index.html";
        };
      };
    };
  };
  nixos.tests.basic = import "${sources.inputs.nixpkgs}/nixos/tests/cryptpad.nix" args;
}
