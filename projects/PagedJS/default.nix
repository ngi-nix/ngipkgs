{
  lib,
  pkgs,
  sources,
  ...
}@args:

{
  metadata = {
    summary = "Javascript library to transform HTML document into print-ready pdf";
    subgrants = [
      "PagedJS"
    ];
    links = {
      documentation = {
        text = "Documentation";
        url = "https://pagedjs.org/en/undefined/";
      };
      source = {
        text = "Source";
        url = "https://github.com/pagedjs/pagedjs/";
      };
      blog = {
        text = "Blog";
        url = "https://www.pagedmedia.org/paged-js.html";
      };

    };
  };

  nixos.modules.programs.pagedjs.module = null;
}
