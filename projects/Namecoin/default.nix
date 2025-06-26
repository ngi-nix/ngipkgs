{
  pkgs,
  lib,
  sources,
  ...
}:
{
  nixos = {
    modules.services.namecoind.module = lib.moduleLocFromOptionString "services.namecoind";
    modules.services.ncdns.module = lib.moduleLocFromOptionString "services.ncdns";
    modules.programs.electrum-nmc.module = null;
    # the namecoind service module does not add namecoin commands to the environment
    modules.programs.namecoin.module = null;

    examples.tor-browser-temporary = {
      description = ''
        To enable experimental Namecoin resolution with Tor Browser, run:

        ```shell-session
        TOR_ENABLE_NAMECOIN=1 tor-browser
        ```
      '';
      module = ./examples/tor-browser-temporary.nix;
      links.documentation.text = "Tor Browser";
      links.documentation.url = "https://www.namecoin.org/download/#tor-browser";
      tests.tor-browser-temporary.module = null;
    };

    examples.tor-browser-permanent = {
      description = ''
        It is also possible to permanently enable experimental Namecoin resolution with Tor Browser.
      '';
      links.documentation.text = "Tor Browser";
      links.documentation.url = "https://www.namecoin.org/download/#tor-browser";
      module = ./examples/tor-browser-permanent.nix;
      tests.tor-browser-permanent.module = null;
    };

    tests.ncdns.module = pkgs.nixosTests.ncdns;
  };

  metadata.subgrants = [
    "Namecoin-ZeroNet"
    "NamecoinCore"
    "Namecoin-Electrum-NMC"
  ];
}
