{
  pkgs,
  lib,
  sources,
}@args:
{
  metadata = {
    summary = '''';
    subgrants = [
      "Mobilizon"
      "Empowering-Mobilizon"
      "Mobilizon-UX"
    ];
  };
  nixos.modules.services = {
    mobilizon = {
      name = "mobilizon";
      module = "${sources.inputs.nixpkgs}/nixos/modules/services/web-apps/mobilizon.nix";
      examples.prod = {
        module = ./example.nix;
        description = "A basic setup to run Mobilizon in an production environment";
      };
      links = {
      };
    };
  };
  nixos.tests.basic = import "${sources.inputs.nixpkgs}/nixos/tests/mobilizon.nix" args;
}
