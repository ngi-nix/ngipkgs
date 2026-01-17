{
  lib,
  pkgs,
  sources,
  ...
}@args:
{
  metadata = {
    summary = ''
      Novel multimodal search and retrieval engine
    '';
    subgrants = {
      Commons = [
        "Re-Isearch-Vector"
      ];
      Review = [
        "Re-iSearch"
      ];
    };
  };
  nixos.modules.programs = {
    re-isearch = {
      module = ./module.nix;
      examples.re-isearch = {
        module = ./example.nix;
        description = "";
        tests.search-document.module = ./test.nix;
      };
      links = {
        handbook = {
          text = "re-Isearch-Handbook (PDF)";
          url = "https://github.com/re-Isearch/re-Isearch/blob/master/docs/re-Isearch-Handbook.pdf";
        };
        build = {
          text = "Build from source";
          url = "https://github.com/re-Isearch/re-Isearch/blob/master/INSTALLATION";
        };
        tests = {
          text = "Testing (Step 5)";
          url = "https://github.com/re-Isearch/re-Isearch/blob/master/INSTALLATION";
        };
      };
    };
  };
}
