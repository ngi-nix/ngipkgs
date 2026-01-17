{
  lib,
  pkgs,
  sources,
  ...
}@args:

{
  metadata = {
    summary = "ActivityPub-powered tool for storing and sharing 3d models";
    subgrants = {
      Commons = [
        "Manyfold-Discovery"
      ];
      Entrust = [
        "Personal-3D-archive"
      ];
    };
    links = {
      website = {
        text = "Website";
        url = "https://manyfold.app/";
      };
      src = {
        text = "Source code";
        url = "https://github.com/manyfold3d/manyfold";
      };
      example = {
        text = "Usage examples";
        url = "https://manyfold.app/get-started/installation";
      };
    };
  };

  nixos = {
    modules.services.manyfold = {
      name = "Manyfold";
      module = ./services/manyfold/module.nix;
      examples = {
        "Enable Manyfold with PostgreSQL" = {
          module = ./services/manyfold/examples/postgresql.nix;
          description = null;
          tests.postgresql.module = ./services/manyfold/tests/postgresql.nix;
          tests.postgresql.problem.broken.reason = ''
            Bundler is unlocking ruby, but the lockfile can't be updated because frozen mode is set (Bundler::ProductionError)
          '';
        };
        "Enable Manyfold with SQLite" = {
          module = ./services/manyfold/examples/sqlite.nix;
          description = null;
          tests.sqlite.module = ./services/manyfold/tests/sqlite.nix;
          tests.sqlite.problem.broken.reason = ''
            Bundler is unlocking ruby, but the lockfile can't be updated because frozen mode is set (Bundler::ProductionError)
          '';
        };
      };
    };
    demo.vm = {
      module = ./services/manyfold/examples/postgresql.nix;
      module-demo = ./demo/module-demo.nix;
      description = "Deployment for demo purposes";
      usage-instructions = [
        {
          instruction = ''
            Visit [http://127.0.0.1:3214](http://127.0.0.1:3214) in your browser
          '';
        }
        {
          instruction = ''
            Follow on screen instructions to create an account and a library.
          '';
        }
        {
          instruction = ''
            Try to upload 3D model assets.
          '';
        }
      ];
      tests.postgresql.module = ./services/manyfold/tests/postgresql.nix;
    };
  };
}
