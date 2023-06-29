{
  description = "NgiPkgs";

  inputs.flake-utils.url = "github:numtide/flake-utils";

  outputs = { self, nixpkgs, flake-utils, ... }:
    flake-utils.lib.eachDefaultSystem (system:
    let
      pkgs = nixpkgs.legacyPackages.${system};
      lib = pkgs.lib;
    in
    {
      packages = lib.makeScope pkgs.newScope (self: import ./all-packages.nix { inherit (self) callPackage; });
      nixosModules = import ./modules/all-modules.nix;
      nixosConfigurations = lib.makeScope pkgs.newScope (self: import ./configs/all-configurations.nix { inherit (self) callPackage; });
    });
}
