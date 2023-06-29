{
  description = "NgiPkgs";

  inputs.flake-utils.url = "github:numtide/flake-utils";

  outputs = { self, nixpkgs, flake-utils, ... }:
    flake-utils.lib.eachDefaultSystem (system:
      let
        pkgs = nixpkgs.legacyPackages.${system};
      in
      {
        packages = import ./all-packages.nix { inherit (pkgs) newScope; };
        nixosModules = {
          liberaforms = import ./modules/liberaforms.nix;
          ngipkgs = { ... }: {
            _module.args.ngipkgs = self.packages.${system};
          };
        };
        nixosConfigurations = {
          # nix build .#nixosConfigurations.x86_64-linux.foo.config.system.build.toplevel
          foo = pkgs.nixos ({ ... }: {
            imports = [
              ./configs/liberaforms/container.nix
              self.nixosModules.${system}.ngipkgs
            ];
          });
        };
      });
}
