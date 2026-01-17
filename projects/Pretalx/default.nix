{
  lib,
  pkgs,
  sources,
  ...
}@args:
let
  # FIX:
  pretalx-test = {
    module = ./test;
    problem.broken.reason = ''
      django.urls.exceptions.NoReverseMatch: Reverse for 'organiser.teams.view' not found. 'organiser.teams.view' is not a valid view function or pattern name.
    '';
  };
in
{
  metadata = {
    summary = "Open source tooling for events and conferences";
    subgrants.Entrust = [
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
        tests.pretalx = pretalx-test;
      };
      postgresql = {
        module = ./examples/postgresql.nix;
        description = ''
          Supplementary to `base.nix`, adds database configuration for PostgreSQL.
        '';
        tests.pretalx-psql = pretalx-test;
      };
      mysql = {
        module = ./examples/mysql.nix;
        description = ''
          Supplementary to `base.nix`, adds database configuration for MySQL.
        '';
        tests.pretalx-mysql = pretalx-test;
      };
    };
  };
}
