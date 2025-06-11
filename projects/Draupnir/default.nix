{
  lib,
  pkgs,
  sources,
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

  nixos.modules.programs.draupnir = null;
  nixos.modules.services.draupnir = null;
}
