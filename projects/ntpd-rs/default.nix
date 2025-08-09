{
  lib,
  pkgs,
  sources,
  ...
}@args:

{
  metadata = {
    summary = "Memory-safe implementation of IETF time standards including NTPv5 and NTS";
    subgrants = [
      "ntpd-rs"
    ];
    links = {
      website = {
        text = "Project Pendulum";
        url = "https://tweedegolf.nl/en/pendulum";
      };
      docs = {
        text = "ntpd-rs documentation";
        url = "https://docs.ntpd-rs.pendulum-project.org/";
      };
    };
  };

  nixos.modules.services.ntpd-rs = {
    name = "ntpd-rs";
    module = lib.moduleLocFromOptionString "services.ntpd-rs";
    examples = {
      "Replace the default `timesyncd` service with `ntpd-rs`" = {
        module = ./examples/basic.nix;
        tests.basic.module = import ./tests/basic.nix args;
      };

      "Use NTS (Network Time Security) servers instead with `ntpd-rs`" = {
        module = ./examples/nts.nix;
        tests.nts.module = import ./tests/nts.nix args;
      };

      "Run `ntpd-rs` in server mode with observability features" = {
        module = ./examples/server.nix;
        tests.server.module = pkgs.nixosTests.ntpd-rs;
      };
    };
  };

  nixos.demo.vm = {
    module = ./examples/basic.nix;
    description = "Replace the default `timesyncd` service with `ntpd-rs`";
    tests.basic.module = import ./tests/basic.nix args;
  };
}
