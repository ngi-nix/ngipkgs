{
  lib,
  pkgs,
  sources,
  ...
}@args:

{
  metadata = {
    summary = "Verso is a new browser initiative that is based on the Servo browser engine";
    subgrants = {
      Core = [
        "Verso-Views"
        "Verso-WebView"
      ];
      Review = [
        "Verso"
        "Verso-Profile"
      ];
    };
  };

  nixos.modules.programs = {
    verso = {
      name = "verso";
      module = ./programs/verso/module.nix;
      examples."Enable verso" = {
        module = ./programs/verso/examples/basic.nix;
        description = "";
        # TODO: can't figure out a way to specify a website for verso to open.
        tests.basic.module = null;
      };
    };
  };
}
