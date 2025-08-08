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

  nixos.modules.programs = {
    pagedjs = {
      module = ./programs/pagedjs/module.nix;
      examples."Enable pagedjs" = {
        module = ./programs/pagedjs/examples/pagedjs.nix;
        description = ''
          Enables PagedJS program.
        '';
        tests.basic.module = import ./programs/pagedjs/tests/pagedjs.nix args;
      };
    };
  };

  nixos.demo.shell = {
    module = ./programs/pagedjs/examples/pagedjs.nix;
    description = ''
      A simple HTML file has been created at `/etc/pagedjs.html` for testing.

      Run `pagedjs-cli --help` to see available commands.

      To create a PDF from the HTML file, use:

      `$ pagedjs-cli -i /etc/pagedjs.html -o ~/pagedjs-example.pdf`

      View the PDF using evince:

      `$ evince ~/pagedjs-example.pdf`
    '';
    tests.basic.module = import ./programs/pagedjs/tests/pagedjs.nix args;
  };
}
