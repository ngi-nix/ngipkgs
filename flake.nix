{
  description = "GNU Anastasis is a key backup and recovery tool from the GNU project.";
  inputs.nixpkgs.url = "github:JosephLucas/nixpkgs/anastasis";
  outputs = { self, nixpkgs }:
    let
      supportedSystems = [ "x86_64-linux" ];
      forAllSystems = f: nixpkgs.lib.genAttrs supportedSystems (system: f system);
      nixpkgsFor = forAllSystems (system: import nixpkgs { inherit system; overlays = [ self.overlay ]; });
    in
    {
      overlay = final: prev: { anastasis = (final.callPackage ./default.nix {}); };
      packages = forAllSystems (system: { inherit (nixpkgsFor.${system}) anastasis; });
      defaultPackage = forAllSystems (system: self.packages.${system}.anastasis);
      # FIXME: check also for x86_64-darwin as soon as Hydra will check darwin derivations
      checks.x86_64-linux.anastasis = self.packages.x86_64-linux.anastasis;
      devShell = self.defaultPackage;
  };
}
