{
  lib,
  pkgs,
  sources,
  ...
}@args:
{
  metadata = {
    summary = ''
      CryptoLyzer is a cybersecurity tool that can analyse cryptographic settings of clients and servers for different protocols, and test endpoints against a set of known vulnerabilities.
    '';
    subgrants = [
      "CryptoLyzer"
    ];
  };
  # TODO: add a type for pure Nixpkgs stuff
  # nixpkgs.python.extensions.packages = {
  #   cryptolyzer.meta = {
  #     TODO broken = true;
  #     links = {
  #       python-api = {
  #         text = "Python API documentation";
  #         url = "https://cryptolyzer.readthedocs.io/en/latest/api/";
  #       };
  #     };
  #   };
  # };
  nixos = {
    modules.programs.cryptolyzer = {
      module =
        {
          config,
          lib,
          pkgs,
          ...
        }:
        let
          cfg = config.programs.cryptolyzer;
        in
        {
          options.programs.cryptolyzer = {
            enable = lib.mkEnableOption "CryptoLyzer";
            package = lib.mkPackageOption pkgs [ "python3Packages" "cryptolyzer" ] { };
          };
          config.environment.systemPackages = lib.mkIf cfg.enable [ cfg.package ];
        };
      links = {
        development = {
          text = "Development environment with `pipenv`";
          url = "https://cryptolyzer.readthedocs.io/en/latest/development/";
        };
        cli = {
          text = "Command-line interface documentation";
          url = "https://cryptolyzer.readthedocs.io/en/latest/cli/";
        };
        installation = {
          text = "General installation instructions";
          url = "https://cryptolyzer.readthedocs.io/en/latest/installation/";
        };
      };
    };
    # TODO: this absolute basic example, which may show up just about anywhere, can probably extracted into a pattern with two parameters: the program module and the command to run for the smoke test
    examples.basic = {
      module = ./example.nix;
      description = "";
      tests.basic = import ./test.nix args;
    };
  };
}
