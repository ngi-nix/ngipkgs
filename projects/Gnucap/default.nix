{
  lib,
  pkgs,
  sources,
  ...
}@args:

{
  name = "Gnucap";
  metadata = {
    summary = "Gnucap is the GNU Circuit Analysis Package";
    subgrants = [
      "Gnucap-MixedSignals"
      "Gnucap-VerilogAMS"
      "Gnucap-performance"
    ];
  };

  nixos = {
    modules.programs.gnucap = {
      module = ./programs.nix;

      examples.gnucap = {
        module = ./example.nix;
        description = "";
        tests.basic.module = import ./test.nix args;
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
