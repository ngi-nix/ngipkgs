{
  lib,
  pkgs,
  sources,
  ...
}@args:

{
  metadata = {
    summary = "Web browser, designed to empower users to find and filter information on the Internet";
    subgrants = {
      Entrust = [
        "Nyxt-Webextensions"
      ];
      Review = [
        "NyxtBrowser"
        "NyxtUserhosted"
      ];
    };
  };

  nixos.modules.programs = {
    nyxt = {
      name = "nyxt";
      module = ./programs/nyxt/module.nix;
      examples."Enable Nyxt" = {
        module = ./programs/nyxt/examples/basic.nix;
        description = "Enable the nyxt program";
        tests.basic.module = ./programs/nyxt/tests/shell.nix;
      };
    };
  };

  nixos.demo.shell = {
    module = ./programs/nyxt/examples/basic.nix;
    description = "nyxt demo";
    tests.basic.module = ./programs/nyxt/tests/shell.nix;
  };
}
