
  {
  pkgs,
  lib,
  sources,
  ...
}@args:
{

   metadata = {
    summary = "Gancio Shared agenda for local communities that supports Activity";
    subgrants = [
      "gancio"
      "Hex designs"
    ];
  };

  
  nixos = {
     module.programs.gancio = {
      module = "";


      examples.gancio = {
        module = "./example.nix";
        description ="";
        tests.basic = null;
    

    };


    links ={
      text ="gancio project website";
      url="https://nlnet.nl/project/Gancio/";
    };
     };
  };
}
