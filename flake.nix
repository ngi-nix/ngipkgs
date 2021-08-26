{
  description = "Weblate package and module";

  inputs.nixpkgs.url = "github:NixOS/Nixpkgs/nixos-unstable";
  inputs.poetry2nix.url = "github:erictapen/poetry2nix/overrides";
  inputs.weblate.url = "github:WeblateOrg/weblate/weblate-4.7.2";
  inputs.weblate.flake = false;

  outputs = { self, nixpkgs, poetry2nix, weblate }:
    let
      pkgs = import nixpkgs {
        system = "x86_64-linux";
        overlays = [ poetry2nix.overlay ];
      };
    in
    {

      packages.x86_64-linux.weblate = pkgs.poetry2nix.mkPoetryApplication {
        src = weblate;
        pyproject = ./pyproject.toml;
        poetrylock = ./poetry.lock;
        meta = with pkgs.lib; {
          description = "Web based translation tool with tight version control integration";
          homepage = https://weblate.org/;
          license = licenses.gpl3Plus;
          maintainers = with maintainers; [ erictapen ];
        };

      };

      defaultPackage.x86_64-linux = self.packages.x86_64-linux.weblate;

      nixosModules.weblate = ./module.nix;

      overlay = _: _: {
        inherit (self.packages.x86_64-linux) weblate;
      };

      checks.x86_64-linux.integrationTest =
        let
          # As pkgs doesn't contain the weblate package and module, we have to
          # evaluate Nixpkgs again.
          pkgsWeblate = import nixpkgs {
            system = "x86_64-linux";
            overlays = [ self.overlay ];
          };
        in
        pkgsWeblate.nixosTest (import ./integration-test.nix self.nixosModules.weblate);

    };
}
