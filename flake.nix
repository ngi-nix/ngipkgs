{
  description = "NgiPkgs";

  inputs.systems.url = "github:nix-systems/x86_64-linux";
  inputs.flake-utils.url = "github:numtide/flake-utils";
  inputs.flake-utils.inputs.systems.follows = "systems";

  outputs = { self, nixpkgs, flake-utils, ... }:
    flake-utils.lib.eachDefaultSystem
      (system:
        let
          pkgs = nixpkgs.legacyPackages.${system};
        in
        {
          packages = import ./all-packages.nix { inherit (pkgs) newScope; };
          nixosModules = {
            modules = import ./modules/all-modules.nix;
            ngipkgs = { ... }: {
              # inject an additional argument into the module system evaluation.
              # this way our package set can be accessed separately and we don't have
              # to muck around with overlays (which don't work with flakes as you'd expect)
              _module.args.ngipkgs = self.packages.${system};
            };
          };
          # XXX: fugly hack to work around literal quoting of attribute paths passed to `nixos-container`.
          # without it we'd have to pass `x86_64-linux.<container>`, which will
          # be taken as a single attribute name and not an attribute path (i.e. a dot-separated
          # sequence attribute names)
        }) // {
      nixosConfigurations =
        let
          pkgs = nixpkgs.legacyPackages.x86_64-linux;
          all-configurations = import ./configs/all-configurations.nix { inherit pkgs; };
          inject-ngipkgs = k: v: pkgs.nixos ({ ... }: { imports = [ self.nixosModules.x86_64-linux.ngipkgs v ]; });
        in
        builtins.mapAttrs inject-ngipkgs all-configurations;

      hydraJobs = {
        packages.x86_64-linux = self.packages.x86_64-linux;
      };

    };

}
