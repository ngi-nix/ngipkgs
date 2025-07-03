{
  lib,
  pkgs,
  sources,
  ...
}@args:

{
  metadata = {
    summary = "Nominatim is an open-source geographic search engine (geocoder).";
    subgrants = [
      "Nominatim"
      "Nominatim-lib"
    ];
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
      module = null;
    };
  };

  nixos.modules.services = {
    nominatim = {
      name = "nominatim";
      module = lib.moduleLocFromOptionString "services.nominatim";
      examples."Nominatim service with API, UI and CLI support" = {
        module = ./services/nominatim/examples/basic.nix;
        tests.basic.module = import ./services/nominatim/tests/basic.nix args;
      };
    };
  };

  nixos.demo.vm = {
    module = ./services/nominatim/examples/basic.nix;
    description = ''
      A demo VM for testing Nominatim.

      1. First, download some OpenStreetMap data from
      [Geofabrik.de](https://download.geofabrik.de/), for example Andorra.

      $ cd /tmp
      $ wget https://download.geofabrik.de/europe/andorra-latest.osm.pbf

      2. Import data to Nominatim database

      $ sudo -u nominatim \
        NOMINATIM_DATABASE_WEBUSER=nominatim-api \
        nominatim import --continue import-from-file --osm-file andorra-latest.osm.pbf

      3. Restart Nominatim service

      $ sudo systemctl restart nominatim.service

      4. Test Nominatim API in terminal

      $ curl -k https://localhost:8443/status
      $ curl -k "https://localhost:8443/search?q=Andorra&format=geojson"

      5. Test Nominatim UI in browser

      $ open https://localhost:8443
    '';

    tests.demo.module = import ./services/nominatim/tests/basic.nix args;
  };
}
