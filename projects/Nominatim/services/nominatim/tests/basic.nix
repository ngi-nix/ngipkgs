{
  sources,
  pkgs,
  ...
}:

let
  # Andorra - the smallest dataset in Europe (3.1 MB)
  osmData = pkgs.fetchurl {
    url = "https://web.archive.org/web/20250430211212/https://download.geofabrik.de/europe/andorra-latest.osm.pbf";
    hash = "sha256-Ey+ipTOFUm80rxBteirPW5N4KxmUsg/pCE58E/2rcyE=";
  };
in
{
  name = "nominatim-demo";

  nodes = {
    machine =
      { ... }:
      {
        imports = [
          sources.modules.ngipkgs
          sources.modules.services.nominatim
          sources.examples.Nominatim."Nominatim service with API, UI and CLI support"
        ];
      };
  };

  testScript = ''
    start_all()

    machine.wait_for_unit("nominatim.service")

    # Import OSM data
    machine.succeed("""
      cd /tmp
      sudo -u nominatim \
        NOMINATIM_DATABASE_WEBUSER=nominatim-api \
        NOMINATIM_IMPORT_STYLE=admin \
        nominatim import --continue import-from-file --osm-file ${osmData}
    """)
    machine.succeed("systemctl restart nominatim.service")

    # Test API
    machine.succeed("""
      curl --insecure "https://localhost:8443/search?q=Andorra&format=geojson" \
      | grep "Andorra"
    """)

    # Test UI
    machine.succeed("""
      curl --insecure --location https://localhost:8443 \
      | grep "<title>Nominatim Demo</title>"
    """)
  '';
}
