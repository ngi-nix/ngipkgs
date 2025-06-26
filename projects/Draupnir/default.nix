{
  lib,
  pkgs,
  sources,
  ...
}@args:

{
  metadata = {
    summary = "Moderation bot for Matrix servers";
    subgrants = [
      "Draupnir"
    ];
    links = {
      install = {
        text = "Build Draupnir from source";
        url = "https://the-draupnir-project.github.io/draupnir-documentation/bot/setup";
      };
      source = {
        text = "GitHub repository";
        url = "https://github.com/the-draupnir-project/Draupnir";
      };
    };
  };

  nixos = {
    modules.services.draupnir = {
      module = lib.moduleLocFromOptionString "services.draupnir";
      examples.basic = {
        module = ./example.nix;
        description = "";
        tests.basic = pkgs.nixosTests.draupnir;
      };
    };
    demo.vm = {
      module = ./example.nix;
      description = "Deployment for demo purposes";
      tests.basic = pkgs.nixosTests.draupnir;
      problem.broken.reason = ''
        Still a work in progress.
      '';
    };
  };
}
