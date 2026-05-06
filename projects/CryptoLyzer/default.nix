{
  lib,
  pkgs,
  sources,
  ...
}@args:
{
  metadata = {
    summary = ''
      Cybersecurity tool that can analyse cryptographic settings of clients and servers for different protocols, and test endpoints against a set of known vulnerabilities.
    '';
    subgrants = {
      Core = [
        "CryptoLyzer-IKE"
      ];
      Review = [
        "CryptoLyzer"
      ];
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
      module = ./programs/module.nix;
      # TODO: this absolute basic example, which may show up just about anywhere, can probably extracted into a pattern with two parameters: the program module and the command to run for the smoke test
      examples."Enable CryptoLyzer" = {
        module = ./programs/examples/example.nix;
        tests.basic.module = ./programs/tests/test.nix;
      };
    };

    demo.shell = {
      module = ./programs/examples/example.nix;
      module-demo = ./module-demo.nix;
      tests.demo.module = ./programs/tests/test.nix;
    };
  };
}
