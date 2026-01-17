{
  lib,
  pkgs,
  sources,
  ...
}@args:

{
  metadata = {
    summary = "Memory-safe implementation of IETF time standards including NTPv5 and NTS";
    subgrants.Entrust = [
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
        tests.basic.module = ./tests/basic.nix;
      };

      "Use NTS (Network Time Security) servers instead with `ntpd-rs`" = {
        module = ./examples/nts.nix;
        tests.nts.module = ./tests/nts.nix;
      };

      "Run `ntpd-rs` in server mode with observability features" = {
        module = ./examples/server.nix;
        tests.server.module = pkgs.nixosTests.ntpd-rs;
      };
    };
  };

  nixos.demo.vm = {
    module = ./examples/basic.nix;
    usage-instructions = [
      {
        instruction = ''
          To use `ntpd-rs`, you need to first disable systemd-timesyncd
          (the default NTP client on NixOS).
        '';
      }
      {
        instruction = ''
          Then pick your time sources and configure them as described
          [in the documentation](https://docs.ntpd-rs.pendulum-project.org/man/ntp.toml.5/).
        '';
      }
      {
        instruction = ''
          The default `synchronization.minimum-agreeing-sources` is 3,
          override it to a lower value if have fewer sources.
          If you start `ntpd-rs` in client mode and having less sources
          than the configured value, the service will exit with an error.
          To check the synchronization status, use `ntp-ctl status`.
        '';
      }
    ];
    tests.basic.module = ./tests/basic.nix;
  };
}
