{
  lib,
  pkgs,
  sources,
  ...
}@args:

{
  metadata = {
    summary = "Nominatim is an open-source geographic search engine (geocoder).";
    subgrants = {
      Entrust = [
        "Nominatim-lib"
      ];
      Review = [
        "Nominatim"
      ];
    };
    links = {
      docs = {
        text = "Documentation";
        url = "https://nominatim.org/release-docs/latest/";
      };
      src = {
        text = "Source repository";
        url = "https://github.com/osm-search/Nominatim";
      };
      src-ui = {
        text = "Source repository (UI)";
        url = "https://github.com/osm-search/nominatim-ui";
      };
    };
  };

  nixos.modules.programs = {
    nominatim = {
      name = "nominatim";
      module = ./programs/nominatim/module.nix;
    };
  };

  nixos.modules.services = {
    nominatim = {
      name = "nominatim";
      module = lib.moduleLocFromOptionString "services.nominatim";
      examples."Nominatim service with API, UI and CLI support" = {
        module = ./services/nominatim/examples/basic.nix;
        tests.basic.module = pkgs.nixosTests.nominatim;
      };
    };
  };

  nixos.demo.vm = {
    module = ./services/nominatim/examples/basic.nix;
    usage-instructions = [
      {
        instruction = ''
          First, download some OpenStreetMap data from
          [Geofabrik.de](https://download.geofabrik.de/), for example Andorra.
        '';
      }
      {
        instruction = ''
          Then, import the data to Nominatim database.
          ```
          $ cd /tmp
          $ wget https://download.geofabrik.de/europe/andorra-latest.osm.pbf

          $ sudo -u nominatim \
            NOMINATIM_DATABASE_WEBUSER=nominatim-api \
            nominatim import --continue import-from-file --osm-file andorra-latest.osm.pbf
          ```
        '';
      }
      {
        instruction = ''
          Restart the Nominatim service.
          ```
          $ sudo systemctl restart nominatim.service
          ```
        '';
      }
      {
        instruction = ''
          Test Nominatim API in terminal.
          ```
          $ curl -k https://localhost:8443/status
          $ curl -k "https://localhost:8443/search?q=Andorra&format=geojson"
          ```
        '';
      }
      {
        instruction = ''
          Test Nominatim UI in browser.
          ```
          $ open https://localhost:8443
          ```
        '';
      }
      {
        instruction = ''
          Restart Nominatim service.
          ```
          $ sudo systemctl restart nominatim.service
          ```
        '';
      }
    ];

    tests.demo.module = pkgs.nixosTests.nominatim;
  };
}
