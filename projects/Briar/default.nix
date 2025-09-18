{
  lib,
  pkgs,
  sources,
  ...
}@args:

{
  metadata = {
    summary = "A censorship-resistant peer-to-peer secure messaging app with offline capabilities";
    subgrants.Review = [
      "Briar"
      "Briar-beyond-Android"
    ];
    links = {
      homepage = {
        text = "Homepage";
        url = "https://briarproject.org/";
      };
      repo = {
        text = "Source repository";
        url = "https://code.briarproject.org/briar/briar-desktop";
      };
      repo-mobile = {
        text = "Source repository (mobile)";
        url = "https://code.briarproject.org/briar/briar";
      };
      docs = {
        text = "Documentation";
        url = "https://briarproject.org/manual";
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
        tests.basic.module = null;
      };
    };
  };
}
