{
  sources,
  pkgs,
  ...
}:

let
  data = pkgs.fetchurl {
    url = "https://r2-public.protomaps.com/protomaps-sample-datasets/cb_2018_us_zcta510_500k.pmtiles";
    hash = "sha256-oj5KsF+nz6b8aQLCVulAUe1DboX7PhaC+K0J68nugs0=";
  };
in
{
  name = "PMTiles";

  nodes = {
    machine =
      { ... }:
      {
        imports = [
          sources.modules.ngipkgs
          sources.modules.programs.pmtiles
          sources.examples.protomaps."PMTiles"
        ];

        programs.pmtiles.enable = true;
        environment.systemPackages = with pkgs; [
          jq
        ];
      };
  };

  testScript =
    { nodes, ... }:
    ''
      start_all()

      machine.succeed("""
        pmtiles show --metadata ${data} \
        | jq ".vector_layers | length"
      """)
    '';
}
