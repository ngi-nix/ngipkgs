{
  lib,
  pkgs,
  sources,
  ...
}@args:
{
  metadata = {
    summary = "Webbased selfhosted PDF manager, viewer and editor";
    subgrants.Commons = [
      "PdfDing"
    ];
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
          tests.basic.module = import ./services/pdfding/tests/basic.nix args;
        };
        postgres = {
          module = ./services/pdfding/examples/postgres.nix;
          description = "Postgres and consume feature";
          tests.postgres.module = import ./services/pdfding/tests/postgres.nix args;
        };
        minio = {
          module = ./services/pdfding/examples/minio.nix;
          description = "Backup feature of pdfding";
          tests.minio.module = import ./services/pdfding/tests/minio.nix args;
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
  nixos.tests.e2e.module = import ./services/pdfding/tests/e2e.nix args;
}
