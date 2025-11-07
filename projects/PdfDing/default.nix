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
          # TODO email is being sent to /var/mail and pdfding logs it to console
          # https://github.com/mrmn2/PdfDing/issues/110
          # there is an smtp setup available, maybe need to test it manually outside of these tests
          description = ''
            Usage instructions

            1. Copy the example and run it
            2. Visit [http://127.0.0.1:8000](http://127.0.0.1:8000) in your browser
            3. Signup to an account with a test email
          '';
          tests.basic.module = import ./services/pdfding/tests/basic.nix args;
        };
        postgres = {
          module = ./services/pdfding/examples/postgres.nix;
          description = ''TODO'';
          tests.postgres.module = import ./services/pdfding/tests/postgres.nix args;
        };
        minio = {
          module = ./services/pdfding/examples/minio.nix;
          description = ''TODO'';
          tests.postgres.module = import ./services/pdfding/tests/minio.nix args;
        };
      };
      links = {
        build = {
          text = "Build from source";
          url = "https://github.com/mrmn2/PdfDing/blob/master/Dockerfile";
        };
        test = {
          text = "Test instructions";
          url = "https://github.com/mrmn2/PdfDing/blob/master/bootstrap.sh"; # TODO maybe not
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
