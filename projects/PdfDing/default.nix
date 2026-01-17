{
  lib,
  pkgs,
  sources,
  ...
}@args:
{
  metadata = {
    summary = "Web-based selfhosted PDF manager, viewer and editor";
    subgrants.Commons = [ "PdfDing" ];
    links = {
      repo = {
        text = "Source repository";
        url = "https://github.com/mrmn2/PdfDing";
      };
      homepage = {
        text = "Homepage";
        url = "https://www.pdfding.com";
      };
      docs = {
        text = "Documentation";
        url = "https://docs.pdfding.com";
      };
    };
  };

  nixos.modules.services = {
    pdfding = {
      module = ./services/pdfding/module.nix;
      examples = {
        basic = {
          module = ./services/pdfding/examples/basic.nix;
          description = "Sqlite default service";
          tests.basic.module = ./services/pdfding/tests/basic.nix;
        };
        postgres = {
          module = ./services/pdfding/examples/postgres.nix;
          description = "Postgres and consume feature";
          tests.postgres.module = ./services/pdfding/tests/postgres.nix;
        };
        minio = {
          module = ./services/pdfding/examples/minio.nix;
          description = "Backup feature of pdfding";
          tests.minio.module = ./services/pdfding/tests/minio.nix;
        };
      };
      links = {
        build = {
          text = "Build from source";
          url = "https://github.com/mrmn2/PdfDing/blob/master/Dockerfile";
        };
      };
    };
  };

  # e2e not tied to an example
  nixos.tests.e2e.module = ./services/pdfding/tests/e2e.nix;

  nixos.demo.vm = {
    module = ./demo/module.nix;
    module-demo = ./demo/module-demo.nix;
    usage-instructions = [
      {
        instruction = ''
          Visit [http://127.0.0.1:8000](http://127.0.0.1:8000) in your browser
        '';
      }
      {
        instruction = ''
          An admin account has already been created inside the demo, so you can sign in with the following credentials:

          - email: `admin@localhost`
          - password: `admin`
        '';
      }
      {
        instruction = ''
          An example file will be available inside the demo, but it might take a minute for it to appear.
          You can upload more PDFs, click ➕ icon (top right corner).

          For example:
          - [https://nix.dev/nix-dev.pdf](https://nix.dev/nix-dev.pdf)
          - [https://edolstra.github.io/pubs/phd-thesis.pdf](https://edolstra.github.io/pubs/phd-thesis.pdf)
        '';
      }
    ];
    tests.demo.module = ./services/pdfding/tests/basic.nix;
  };
}
