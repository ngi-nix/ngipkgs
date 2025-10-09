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
        tests.blint.module = pkgs.nixosTests.blint;
        tests.blint.problem.broken.reason = ''
          Dependency (lief) is failing to build:

          - https://hydra.nixos.org/build/306884435
          - https://github.com/NixOS/nixpkgs/issues/443121
        '';
        tests.depscan.module = pkgs.nixosTests.dep-scan;
      };
    };
  };

  nixos.demo.shell = {
    module = ./programs/owasp/examples/basic.nix;
    usage-instructions = null;
    tests.blint.module = pkgs.nixosTests.blint;
    tests.blint.problem.broken.reason = ''
      Dependency (lief) is failing to build:

      - https://hydra.nixos.org/build/306884435
      - https://github.com/NixOS/nixpkgs/issues/443121
    '';
    tests.depscan.module = pkgs.nixosTests.dep-scan;
  };
}
