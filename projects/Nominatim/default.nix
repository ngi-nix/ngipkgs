{
  lib,
  pkgs,
  sources,
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
      module = null;
    };
  };

  nixos.demo = null;
}
