{
  lib,
  pkgs,
  sources,
  ...
}@args:

{
  metadata = {
    summary = "Library operating system that constructs unikernels";
    subgrants = {
      Core = [
        "Mollymawk"
      ];
      Entrust = [
        "DNSvizor"
      ];
      Review = [
        "MirageVPN"
      ];
    };
    links = {
      repo = {
        text = "Source repository";
        url = "https://github.com/mirage";
      };
      homepage = {
        text = "Homepage";
        url = "https://mirage.io/";
      };
      docs = {
        text = "Documentation";
        url = "https://mirage.io/docs/";
      };
    };
  };

  # TODO: implement missing deliverables
  # - https://github.com/ngi-nix/ngipkgs/blob/main/maintainers/docs/project.md
  # - https://github.com/ngi-nix/ngipkgs/blob/main/maintainers/templates/project/default.nix

  nixos.modules.programs = {
    miragevpn.module = null;
  };

  nixos.modules.services = {
    mollymawk.module = null;
    dnsvizor.module = null;
    miragevpn.module = null;
  };

  nixos.demo = null;

  /*
    TODO: expose libraries from Nixpkgs (check they're related to MirageOS):

    mirage
    mirage-block
    mirage-block-combinators
    mirage-block-ramdisk
    mirage-block-unix
    mirage-bootvar-unix
    mirage-bootvar-xen
    mirage-clock
    mirage-clock-solo5
    mirage-clock-unix
    mirage-console
    mirage-crypto
    mirage-crypto-ec
    mirage-crypto-pk
    mirage-crypto-rng
    mirage-crypto-rng-mirage
    mirage-crypto-rng-miou-unix
    mirage-device
    mirage-flow
    mirage-flow-combinators
    mirage-flow-unix
    mirage-kv
    mirage-logs
    mirage-mtime
    mirage-nat
    mirage-net
    mirage-net-xen
    mirage-profile
    mirage-protocols
    mirage-ptime
    mirage-random
    mirage-random-test
    mirage-runtime
    mirage-sleep
    mirage-time
    mirage-time-unix
    mirage-unix
    mirage-xen
    mirage-vnetif
  */
}
