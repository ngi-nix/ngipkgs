{
  lib,
  pkgs,
  sources,
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

  nixos.modules.services = {
    ntpd-rs = {
      name = "ntpd-rs";
      module = "${sources.inputs.nixpkgs}/nixos/modules/services/networking/ntp/ntpd-rs.nix";
      examples.basic = {
        module = ./services/ntpd-rs/examples/basic.nix;
        description = ''
          Example config for ntpd-rs options is available in tests.
        '';
        tests.ntpd-rs = "${sources.inputs.nixpkgs}/nixos/tests/ntpd-rs.nix";
      };
    };
  };
}
