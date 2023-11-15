{
  description = "(insert short project description here)";

  inputs = {
    nixpkgs.url = "nixpkgs/nixpkgs-unstable";

    npmlock2nix-src = {
      url = "github:nix-community/npmlock2nix";
      flake = false;
    };

    mvn2nix-src.url = "github:fzakaria/mvn2nix";
    mvn2nix-src.inputs.nixpkgs.follows = "nixpkgs";
  };

  outputs = {
    self,
    nixpkgs,
    # sources
    npmlock2nix-src,
    mvn2nix-src,
  }: let
    system = "x86_64-linux";
    pkgs = import nixpkgs {inherit system;};
    mvn2nix = import mvn2nix-src {inherit system;};
    npmlock2nix = import npmlock2nix-src {inherit pkgs;};
  in {
    packages.${system} = with pkgs; {
      jaeger = callPackage pkgs/jaeger {};
      ipfs-sniffer = callPackage pkgs/ipfs-sniffer {};
      ipfs-search-api-server = callPackage pkgs/ipfs-search-api-server {
        inherit npmlock2nix;
      };
      ipfs-crawler = callPackage pkgs/ipfs-crawler {};
      dweb-search-frontend = callPackage pkgs/dweb-search-frontend {};
      tika-extractor = callPackage pkgs/tika-extractor {
        inherit mvn2nix;
      };
    };

    nixosModules.ipfs-search = import modules/ipfs-search;
  };
}
