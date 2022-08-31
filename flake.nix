{
  inputs.dream2nix.url = "github:nix-community/dream2nix";
  inputs.hypercore.url = "github:hypercore-protocol/hypercore";
  inputs.hypercore.flake = false;
  outputs = inp:
    inp.dream2nix.lib.makeFlakeOutputs {
      systemsFromFile = ./nix_systems;
      config.projectRoot = ./.;
      source = inp.hypercore;
    };
}
