{
  lib,
  pkgs,
  sources,
}@args:
{
  

   metadata = {
    summary ="Omnom is a webpage bookmarking and snapshotting service.";
       ' ';
    subgrants = [
      "Omnom"
      "Omnom-ActivityPub"
    ];
  };
  nixos.modules.service.Omnom = {
    Omnom = {
      name = "Omnom";
      module = "${sources.inputs.nixpkgs}/nixos/modules/services/misc/omnom.nix;
      examples.base = null;
      links = {
        development= {
        text = null;
        url = null;
      };     
        description = "Basic Omnom configuration,mainly used for testing purposes.";
        };
        test = null;

        };
      };
    };

 
