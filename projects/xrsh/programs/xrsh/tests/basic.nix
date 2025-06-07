{
  sources,
  ...
}:

{
  name = "xrsh";

  nodes = {
    machine =
      { ... }:
      {
        imports = [
          sources.modules.ngipkgs
          sources.modules.programs.xrsh
          sources.examples.xrsh.basic
        ];
      };
  };

  # TODO: test xrsh

  # Figuring out how to test xrsh is a bit tricky because the program does not
  # have a command line interface, but a web interface that's accessed via
  # a browser. 127.0.0.1:8080 is the default port.

  # A demo test might be more plausiblle as it allows port forwarding
  # to the local browser.

  testScript =
    { nodes, ... }:
    ''
      # start_all()
    '';
}
