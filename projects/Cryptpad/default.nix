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
  nixos.services = {
    cryptpad = {
      name = "cryptpad";
      module =
        { config, ... }:
        let
          cfg = config.services.cryptpad;
        in
        {
          imports = [
            "${sources.inputs.nixpkgs}/nixos/modules/services/web-apps/cryptpad.nix"
          ];

          # TODO: add to nixpkgs
          options.services.cryptpad.openPorts = lib.mkOption {
            type = lib.types.bool;
            default = false;
            description = ''
              Whether to open the port specified in `settings.httpPort` in the firewall.
            '';
          };
          config = lib.mkIf cfg.openPorts {
            networking.firewall.allowedTCPPorts = [ cfg.settings.httpPort ];
            networking.firewall.allowedUDPPorts = [ cfg.settings.httpPort ];
          };
        };
      examples.demo = {
        module = ./demo.nix;
        description = "Deployment for demo purposes";
        # TODO: fixed in nixpkgs, enable after the flake is updated
        # tests.basic = import "${sources.inputs.nixpkgs}/nixos/tests/cryptpad.nix" args;
        tests.basic = null;
      };
      links = {
        admin-guide = {
          text = "Administration guide";
          url = "https://docs.cryptpad.org/en/admin_guide/index.html";
        };
      };
    };
  };
}
