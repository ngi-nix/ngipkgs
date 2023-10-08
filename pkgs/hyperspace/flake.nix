{
  description = "Monorepo holding various Hypercore related packages";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/8b5ab8341e33322e5b66fb46ce23d724050f6606";
    dream2nix = {
      url = "github:nix-community/dream2nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    hyperbeam = {
      url = "github:mafintosh/hyperbeam";
      flake = false;
    };
    corestore = {
      url = "github:hypercore-protocol/corestore";
      flake = false;
    };
    hyperblobs = {
      url = "github:hypercore-protocol/hyperblobs";
      flake = false;
    };
    hyperswarm = {
      url = "github:hyperswarm/hyperswarm";
      flake = false;
    };
  };

  outputs = {
    self,
    nixpkgs,
    dream2nix,
    ...
  } @ inputs: let
    pkgs = import nixpkgs {
      system = "x86_64-linux";
      config.permittedInsecurePackages = [
        "nodejs-16.20.2"
      ];
    };

    mkOuts = source:
      dream2nix.lib.makeFlakeOutputs {
        config.projectRoot = ./.;
        inherit pkgs source;
        settings = [{subsystemInfo.nodejs = 16;}];
      };
  in
    nixpkgs.lib.foldl' nixpkgs.lib.recursiveUpdate {} (map mkOuts [
      inputs.hyperbeam
      inputs.corestore
      inputs.hyperblobs
      inputs.hyperswarm
    ]);
}
