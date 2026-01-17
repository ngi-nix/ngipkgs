{
  lib,
  pkgs,
  sources,
  ...
}@args:

{
  name = "Gnucap";
  metadata = {
    summary = "GNU Circuit Analysis Package";
    subgrants = {
      Commons = [
        "Gnucap-performance"
      ];
      Entrust = [
        "Gnucap-MixedSignals"
        "Gnucap-VerilogAMS"
      ];
    };
  };

  nixos = {
    modules.programs.gnucap = {
      module = ./programs.nix;

      examples.gnucap = {
        module = ./example.nix;
        description = "";
        tests.basic.module = ./test.nix;
      };

      links = {
        userManual = {
          text = "User Manual (PDF)";
          url = "https://www.gnu.org/software/gnucap/gnucap-man.pdf";
        };
        manual = {
          text = "Gnucap manual";
          url = "http://gnucap.org/dokuwiki/doku.php/gnucap:manual";
        };
        tutorial = {
          text = "Examples, tutorial";
          url = "http://gnucap.org/dokuwiki/doku.php/gnucap:manual:examples";
        };
        wiki = {
          text = "Gnucap Wiki";
          url = "http://gnucap.org/dokuwiki/doku.php?id=gnucap:start";
        };
        notes = {
          text = "Notes for Developers";
          url = "http://gnucap.org/dokuwiki/doku.php/gnucap:manual:tech";
        };
      };
    };
  };
}
