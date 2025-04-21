{
  lib,
  pkgs,
  sources,
}@args:

{
  metadata = {
    summary = "A censorship-resistant peer-to-peer secure messaging app with offline capabilities";
    subgrants = [
      "Briar"
      "Briar-beyond-Android"
    ];
    links = {
      website = {
        text = "Briar project website";
        url = "https://briarproject.org/";
      };
    };
  };

  nixos.modules.programs = {
    briar = {
      name = "briar";
      module = ./programs/briar/module.nix;
      examples.basic = {
        module = ./programs/briar/examples/basic.nix;
        description = "";
        tests.basic = null;
      };
    };
  };
}
