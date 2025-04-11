{
  lib,
  pkgs,
  sources,
}@args:

{
  metadata = {
    summary = "Open source software forge with a focus on federation";
    subgrants = [
      "Federated-Forgejo"
      "Forgejo"
    ];
    links = {
      docs = {
        text = "Documentation";
        url = "https://forgejo.org/docs";
      };
    };
  };

  nixos.modules.programs = {
    forgejo = {
      module = ./program/module.nix;
      examples.basic = {
        module = ./program/example.nix;
        description = "";
        tests.basic = null;
      };
    };
  };

  nixos.modules.services = {
    forgejo = {
      module = "${sources.inputs.nixpkgs}/nixos/modules/services/misc/forgejo.nix";
      examples.basic = null;
    };
  };

  # https://github.com/ngi-nix/ngipkgs/pull/773
  nixos.tests = if builtins ? currentSystem then pkgs.nixosTests.forgejo else { };
}
