{
  lib,
  pkgs,
  sources,
  ...
}@args:

{
  metadata = {
    summary = "Unified Graph Process For Mapping Knowledge";
    subgrants = {
      Commons = [
        "SmartSemanticDataLookup"
      ];
    };
    links = {
      repo = {
        text = "Source repository";
        url = "https://github.com/markburgess/SSTorytime";
      };
      homepage = {
        text = "Homepage";
        url = "https://markburgess.org/spacetime.html";
      };
      docs = {
        text = "Documentation";
        url = "https://github.com/markburgess/SSTorytime/blob/main/docs/README.md";
      };
    };
  };

  nixos.modules.programs = {
    sstorytime = {
      module = ./programs/sstorytime/module.nix;
      examples."Enable SSTorytime programs" = {
        module = ./programs/sstorytime/examples/basic.nix;
        tests.basic.module = ./services/sstorytime/tests/basic.nix;
      };
    };
  };

  nixos.modules.services = {
    sstorytime = {
      module = ./services/sstorytime/module.nix;
      examples."Enable SSTorytime server" = {
        module = ./services/sstorytime/examples/basic.nix;
        # TODO: make more complex tests?
        # https://github.com/markburgess/SSTorytime/blob/1aa9255fd8afcae6e76b8555f4b0e938a12207cd/docs/N4L.md
        tests.basic.module = ./services/sstorytime/tests/basic.nix;
      };
    };
  };

  nixos.demo.vm = {
    module = ./demo/module.nix;
    module-demo = ./demo/module-demo.nix;
    usage-instructions = [
      {
        instruction = ''
          Download an `n4l` example file from the [SSTorytime repository](https://github.com/markburgess/SSTorytime/tree/main/examples), like `SSTorytime.n4l`, and ingest it with the following command:

          ```shellSession
          $ wget https://raw.githubusercontent.com/markburgess/SSTorytime/refs/heads/main/examples/SSTorytime.n4l
          $ N4L -u SSTorytime.n4l
          ```

          This will transform the file to a graph and upload it to the database.
        '';
      }
      {
        instruction = ''
          Search for a term in the graph with the command line:

          ```shellSession
          searchN4L -v SSTorytime
          ```
        '';
      }
      {
        instruction = ''
          Or visit [http://127.0.0.1:3030](http://127.0.0.1:3030) in your browser for a visual search
        '';
      }
      {
        instruction = ''
          Check out the [documentation](https://github.com/markburgess/SSTorytime/tree/main/docs) for more usage examples.
        '';
      }
    ];
    tests.demo.module = ./services/sstorytime/tests/basic.nix;
  };
}
