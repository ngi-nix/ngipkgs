{
  lib,
  pkgs,
  sources,
}@args:

{
  name = "Proximity matcher";
  metadata = {
    summary = ''
      Webservice for proximity matching using TLSH and Vantage Point Trees.
    '';
    subgrants = [ ];
  };

  nixos = {
    modules = {
      programs = null;
      services = null;
    };

    tests = null;
    examples = null;

    # links = {
    #   documentation = {
    #     text = "Documentation";
    #     url = "https://github.com/armijnhemel/proximity_matcher_webservice/blob/main/README.md";
    #   };
    # };
  };
}
