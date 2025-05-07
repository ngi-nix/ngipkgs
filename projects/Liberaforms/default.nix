{
  lib,
  pkgs,
  sources,
}@args:

{
  metadata = {
    summary = "Free and libre software solution to create online, end-to-end encrypted forms";
    subgrants = [
      # Review
      "Liberaforms"
      "LiberaForms-E2EE"
    ];
  };

  nixos.services.liberaforms = {
    module = ./service.nix;
    examples.basic = {
      module = ./example.nix;
      description = "";
      tests.liberaforms = import ./test.nix args;
    };
  };
}
