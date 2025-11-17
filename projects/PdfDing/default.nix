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
      links = {
        build = {
          text = "Build from source";
          url = "https://github.com/mrmn2/PdfDing/blob/master/Dockerfile";
        };
      };
    };
  };
}
