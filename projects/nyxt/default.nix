{
  lib,
  pkgs,
  sources,
  ...
}@args:

{
  metadata = {
    summary = "Nyxt is a new type of web browser designed to empower users to find and filter information on the Internet";
    subgrants = [
      "Nyxt-Webextensions"
      "NyxtBrowser"
      "NyxtUserhosted"
    ];
  };

  nixos.modules.programs = {
    nyxt = {
      name = "nyxt";
      module = ./programs/nyxt/module.nix;
      examples."Enable Nyxt" = {
        module = ./programs/nyxt/examples/basic.nix;
        tests.basic.module = import ./programs/nyxt/tests/basic.nix args;
      };
    };
  };
}
