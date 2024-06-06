{
  pkgs,
  lib,
  sources,
} @ args: {
  packages = {
    inherit (pkgs) pretalxFull;
  };

  nixos = {
    modules.services.ngi-pretalx = ./service.nix;
    tests.pretalx = import ./test args;
    examples = {
      base = {
        path = ./examples/base.nix;
        description = ''
          Basic configuration for Pretalx, incl. secret management with SOPS, excl. database settings.
        '';
      };
      postgresql = {
        path = ./examples/postgresql.nix;
        description = ''
          Supplementary to `base.nix`, adds database configuration for PostgreSQL.
        '';
      };
      mysql = {
        path = ./examples/mysql.nix;
        description = ''
          Supplementary to `base.nix`, adds database configuration for MySQL.
        '';
      };
    };
  };
}
