{
  lib,
  pkgs,
  sources,
  ...
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
      quickstart = {
        text = "Quick start";
        url = "https://briarproject.org/quick-start";
      };
    };
  };

  nixos.modules.programs = {
    briar = {
      name = "briar";
      module = ./programs/briar/module.nix;
      examples."Enable briar" = {
        module = ./programs/briar/examples/basic.nix;
        description = "";
        tests.basic.module = import ./programs/briar/tests/basic.nix args;
        tests.basic.problem.broken.reason = ''
          Peers can't connect through WiFi.
        '';
      };
    };
  };

  nixos.demo.shell = {
    module = ./programs/briar/examples/basic.nix;
    module-demo = ./module-demo.nix;
    description = "";
    tests.demo.module = import ./programs/briar/tests/basic.nix args;
    tests.demo.problem.broken.reason = ''
      Peers can't connect through WiFi in the test.
    '';
  };
}
