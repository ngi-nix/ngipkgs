{
  pkgs,
  lib,
  sources,
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
      module = "${sources.inputs.nixpkgs}/nixos/modules/services/web-apps/cryptpad.nix";
      examples.basic = null;
      links = {
        admin-guide = {
          text = "Administration guide";
          url = "https://docs.cryptpad.org/en/admin_guide/index.html";
        };
      };
    };
  };
}
