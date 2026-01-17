{
  lib,
  ...
}@args:

{
  metadata = {
    summary = "Encoding for Robust Immutable Storage (ERIS)";
    subgrants.Review = [
      "ERIS"
    ];
    links = {
      homepage = {
        text = "ERIS homepage";
        url = "https://eris.codeberg.page";
      };
      standard = {
        text = "ERIS standard";
        url = "https://eris.codeberg.page/spec/";
      };
      forge = {
        text = "ERIS source code";
        url = "https://codeberg.org/eris";
      };
      irc = {
        text = "ERIS IRC channel";
        url = "ircs://irc.libera.chat:6697/#eris";
      };
    };
  };

  nixos.modules.programs = {
    eris-go = {
      name = "ERIS Go";
      module = null; # removed, upstream
      examples.basic = {
        module = ./programs/eris-go/examples/basic.nix;
        description = "";
        tests.basic.module = null;
      };
      links = {
        manual = {
          text = "Man page";
          url = "https://codeberg.org/eris/eris-go/src/branch/trunk/eris-go.1.md";
        };
      };
    };
  };

  nixos.modules.services = {
    eris-server = {
      name = "ERIS server";
      module = null; # removed, upstream
      examples.basic = {
        module = ./services/eris-server/examples/basic.nix;
        description = "";
        tests.basic.module = ./services/eris-server/tests/basic.nix;
        tests.basic.problem.broken.reason = ''
          Removed, upstream: https://github.com/NixOS/nixpkgs/pull/439158
        '';
      };
      links = {
        build = {
          text = "ERIS server manual";
          url = "https://codeberg.org/eris/eris-go/src/branch/trunk/eris-go.1.md#server";
        };
      };
    };
  };
}
