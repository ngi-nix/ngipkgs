{
  description = "Monorepo holding various Hypercore related packages";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
    dream2nix = { url = "github:nix-community/dream2nix"; inputs.nixpkgs.follows = "nixpkgs"; };
    hyperbeam = { url = "github:mafintosh/hyperbeam"; flake = false; };
    hypercore = { url = "github:hypercore-protocol/hypercore"; flake = false; };
    corestore = { url = "github:hypercore-protocol/corestore"; flake = false; };
    hyperblobs = { url = "github:hypercore-protocol/hyperblobs"; flake = false; };
    autobase = { url = "github:hypercore-protocol/autobase"; flake = false; };
    hyperswarm = { url = "github:hyperswarm/hyperswarm"; flake = false; };
  };

  outputs = { self, nixpkgs, dream2nix, ... }@inputs:
    let
      mkOuts = source: dream2nix.lib.makeFlakeOutputs {
        systems = [ "x86_64-linux" ];
        config.projectRoot = ./.;
        inherit source;
        settings = [{ subsystemInfo.nodejs = 16; }];
      };
    in
    nixpkgs.lib.foldl' nixpkgs.lib.recursiveUpdate { } (map mkOuts [
      inputs.hyperbeam
      inputs.hypercore
      inputs.corestore
      inputs.hyperblobs
      inputs.autobase
      inputs.hyperswarm
    ]);
}
