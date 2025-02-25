{
  pkgs,
  lib,
  sources,
}:
{
  nixos = {
    modules.services.namecoind = "${sources.inputs.nixpkgs}/nixos/modules/services/networking/namecoind.nix";
    modules.services.ncdns = "${sources.inputs.nixpkgs}/nixos/modules/services/networking/ncdns.nix";
    modules.nixos.programs.electrum-nmc = null;
    # the namecoind service module does not add namecoin commands to the environment
    modules.nixos.programs.namecoin = null;

    examples.tor-browser-temporary = {
      description = ''
        To enable experimental Namecoin resolution with Tor Browser, run:

        TOR_ENABLE_NAMECOIN=1 tor-browser
      '';
      path = ./examples/tor-browser-temporary.nix;
      documentation = "https://www.namecoin.org/download/#tor-browser";
    };

    examples.tor-browser-permanent = {
      description = ''
        It is also possible to permanently enable experimental Namecoin resolution with Tor Browser.
      '';
      documentation = "https://www.namecoin.org/download/#tor-browser";
      path = ./examples/tor-browser-permanent.nix;
    };

    tests.ncdns = "${sources.inputs.nixpkgs}/nixos/tests/ncdns.nix";
  };

  subgrants = [
    "Namecoin-ZeroNet"
    "NamecoinCore"
    "Namecoin-Electrum-NMC"
  ];
}
