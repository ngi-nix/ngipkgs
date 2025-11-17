args: {
  metadata = {
    summary = "Webbased selfhosted PDF manager, viewer and editor";
    subgrants.Commons = [ "PdfDing" ];
    links = {
      repo = {
        text = "Source repository";
        url = "https://github.com/mrmn2/PdfDing";
      };
      homepage = {
        text = "Repository Readme";
        url = "https://github.com/mrmn2/PdfDing/blob/master/README.md";
      };
      docs = {
        text = "Documentation";
        url = "https://github.com/mrmn2/PdfDing/blob/master/docs/guides.md";
      };
    };
  };

  nixos.modules.services = {
    pdfding = {
      name = "PdfDing";
      module = ./services/pdfding/module.nix;
      examples = {
        basic = {
          module = ./services/pdfding/examples/basic.nix;
          description = ''
            Usage instructions

            - Copy the example and run it
            - Visit [http://127.0.0.1:8000](http://127.0.0.1:8000) in your browser
            - Signup to an account with a test email
          '';
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
        e2e = {
          module = ./services/pdfding/examples/basic.nix;
          description = "End to end tests of pdfding";
          tests.e2e.module = import ./services/pdfding/tests/e2e.nix args;
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

  nixos.demo.vm = {
    module = ./demo/module.nix;
    module-demo = ./demo/module-demo.nix;
    usage-instructions = [
      {
        instruction = ''
          Visit [http://127.0.0.1:8000](http://127.0.0.1:8000) in your browser
        '';
      }
    ];
    tests.demo.module = import ./services/pdfding/tests/postgres.nix args;
  };
}
