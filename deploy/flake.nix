{
  description = "An example deployment of NGIpkgs software to a local VM";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    ngipkgs.url = "github:ngi-nix/ngipkgs";
  };

  outputs = { self, nixpkgs, ngipkgs }: {

    nixosConfigurations.myMachine = nixpkgs.lib.nixosSystem {
      system = "x86_64-linux";
      modules = [
        ./configuration.nix
        ngipkgs.nixosModules.default

        ### VULA
        # ngipkgs.nixosModules."services.vula"
        # ../projects/Vula/example-simple.nix
        ###
        ### KBIN
        # ngipkgs.nixosModules."services.kbin"
        # ../projects/Kbin/example.nix
        ###
        ### PEERTUBE
        # ngipkgs.nixosModules."services.peertube"
        # ../projects/PeerTube/example.nix
        ###
        ### ATOMICDATA
        # ngipkgs.nixosModules."services.atomic-server"
        # ../projects/AtomicData/example.nix
        ###

      ];
    };
  };
}
