{
  lib,
  pkgs,
  sources,
  ...
}@args:

{
  metadata = {
    summary = "Free and open source map of the world, deployed as a single file you can host yourself";
    subgrants = {
      Core = [
        "Protomaps"
      ];
    };
    links = {
      repo = {
        text = "Source repositories";
        url = "https://github.com/protomaps";
      };
      homepage = {
        text = "Homepage";
        url = "https://protomaps.com/";
      };
      docs = {
        text = "Documentation";
        url = "https://docs.protomaps.com/";
      };
    };
  };

  nixos.modules.programs = {
    pmtiles = {
      name = "PMTiles";
      module = ./programs/pmtiles/module.nix;
      examples."PMTiles" = {
        module = ./programs/pmtiles/examples/basic.nix;
        tests.basic.module = import ./programs/pmtiles/tests/basic.nix args;
      };
    };
  };

  # nixos.modules.services = {
  #   _serviceName_ = {
  #     name = "service name";
  #     module = ./services/_serviceName_/module.nix;
  #     examples."Enable _serviceName_" = {
  #       module = ./services/_serviceName_/examples/basic.nix;
  #       description = ''
  #         Usage instructions

  #         1.
  #         2.
  #         3.
  #       '';
  #       tests.basic.module = import ./services/_serviceName_/tests/basic.nix args;
  #     };
  #     # Add relevant links to the program (optional)
  #     links = {
  #       build = {
  #         text = "Build from source";
  #         url = "<URL>";
  #       };
  #       test = {
  #         text = "Test instructions";
  #         url = "<URL>";
  #       };
  #     };
  #   };
  # };

  nixos.demo.shell = {
    module = ./demo/module.nix;
    module-demo = ./demo/module-demo.nix;
    usage-instructions = [
      {
        instruction = ''
          Download data in pmtiles format:

          ```
            wget https://r2-public.protomaps.com/protomaps-sample-datasets/cb_2018_us_zcta510_500k.pmtiles -O data.pmtiles
          ```
        '';
      }
      {
        instruction = ''
          Show metadata

          ```
            pmtiles show --metadata ./data.pmtiles
          ```
        '';
      }
    ];
    tests.demo.module = import ./programs/pmtiles/tests/basic.nix args;
  };
}
