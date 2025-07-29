{
  lib,
  pkgs,
  sources,
  ...
}@args:

{
  metadata = {
    summary = "Dependency scanner server, and versatile binary linter, malware research tool and SBOM generator";
    subgrants = [
      "OWASP-dep-scan"
      "OWASP-blint"
    ];
  };

  nixos.modules.programs = {
    owasp = {
      name = "owasp";
      # if a project has `packages`, add them inside the `module.nix` file
      module = ./programs/owasp/module.nix;
      examples."Enable owasp" = {
        module = ./programs/owasp/examples/basic.nix;
        description = "Enable the owasp tools";
        tests.blint.module = import ./programs/owasp/tests/blint.nix args;
        # I'm having trouble writing a dep-scan test that doesn't rely on the internet.
        # I'm trying to get some support from upstream, so I'll leave this commented out
        # for now and will write one when I figure it out.
      };
    };
  };

  nixos.demo.shell = {
    module = ./programs/owasp/examples/basic.nix;
    description = "owasp usage examples";
    tests.blint.module = import ./programs/owasp/tests/blint.nix args;
    # I'm having trouble writing a dep-scan test that doesn't rely on the internet.
    # I'm trying to get some support from upstream, so I'll leave this commented out
    # for now and will write one when I figure it out.
  };
}
