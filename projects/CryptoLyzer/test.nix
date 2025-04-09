{
  sources,
  ...
}:
{
  name = "cryptolyzer-help";

  nodes = {
    machine =
      { ... }:
      {
        imports = [
          sources.modules.ngipkgs
          sources.modules.programs.cryptolyzer
          sources.examples.CryptoLyzer.basic
        ];
      };
  };

  testScript =
    { nodes, ... }:
    ''
      start_all()

      machine.succeed("cryptolyze --help")
    '';
}
