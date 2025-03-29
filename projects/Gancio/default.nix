{
  pkgs,
  lib,
  sources,
}@args:
{
  metadata = {
    summary = "Gancio Shared agenda for local communities that supports Activity";
      subgrants = [
        "gancio"
        "hex designs"
      ];
  };
  nixos.modules.programs = {
    gancio = {
      module = "${sources.inputs.nixpkgs}/nixos/modules/services/web-apps/gancio.nix" ;
      examples.gancio ={
        module = ./example.nix ;
        description = "" ;
        tests.basic = null ;
      };  
    };
  };
} 
