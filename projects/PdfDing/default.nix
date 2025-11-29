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
        };
        postgres = {
          module = ./services/pdfding/examples/postgres.nix;
          description = "Postgres and consume feature";
        };
        minio = {
          module = ./services/pdfding/examples/minio.nix;
          description = "Backup feature of pdfding";
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
}
