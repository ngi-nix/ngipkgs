{
  lib,
  pkgs,
  sources,
}@args:

{
  metadata = {
    summary = "Open source tooling for events and conferences";
    subgrants = [
      "Pretalx"
    ];
  };

  nixos.modules.services.ngi-pretalx = {
    module = ./service.nix;
    examples = {
      base = {
        module = ./examples/base.nix;
        description = ''
          Basic configuration for Pretalx, incl. secret management with SOPS, excl. database settings.
        '';
        tests.pretalx = import ./test args;
      };
      postgresql = {
        module = ./examples/postgresql.nix;
        description = ''
          Supplementary to `base.nix`, adds database configuration for PostgreSQL.
        '';
        tests.pretalx = import ./test args;
      };
      mysql = {
        module = ./examples/mysql.nix;
        description = ''
          Supplementary to `base.nix`, adds database configuration for MySQL.
        '';
        tests.pretalx = import ./test args;
      };
    };
  };
}
