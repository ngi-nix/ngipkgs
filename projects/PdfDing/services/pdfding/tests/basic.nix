{
  lib,
  pkgs,
  sources,
  ...
}:
let
  baseTestFile = pkgs.path + "/nixos/tests/web-apps/pdfding/basic.nix";
  baseTest = import baseTestFile { inherit pkgs lib; };
in
{
  inherit (baseTest)
    name
    testScript
    interactive
    meta
    ;

  nodes = lib.mapAttrs (
    _: nodeConfig:
    { config, pkgs, ... }:
    {
      imports = [
        sources.modules.ngipkgs
        sources.modules.services.pdfding
        sources.examples.PdfDing.basic
        "${sources.inputs.sops-nix}/modules/sops"
        nodeConfig
      ];

      sops = lib.mkForce {
        age.keyFile = "/run/keys.txt";
        defaultSopsFile = ./sops/pdfding.yaml;
      };

      # must run before sops sets up keys
      boot.initrd.postDeviceCommands = ''
        cp -r ${./sops/keys.txt} /run/keys.txt
        chmod -R 700 /run/keys.txt
      '';

      services.pdfding.secretKeyFile = lib.mkForce config.sops.secrets."pdfding/django/secret_key".path;
    }
  ) baseTest.nodes;
}
