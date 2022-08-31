{
  inputs.dream2nix.url = "github:nix-community/dream2nix";
  inputs.hyperbeam.url = "github:mafintosh/hyperbeam";
  inputs.hyperbeam.flake = false;
  outputs = inp:
    inp.dream2nix.lib.makeFlakeOutputs {
      systemsFromFile = ./nix_systems;
      config.projectRoot = ./.;
      source = inp.hyperbeam;
    };
}
