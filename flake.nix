{
  description = "Weblate package and module";

  inputs.nixpkgs.url = "github:NixOS/Nixpkgs/nixos-unstable";
  inputs.poetry2nix.url = "github:nix-community/poetry2nix/master";
  inputs.poetry2nix.inputs.nixpkgs.follows = "nixpkgs";
  inputs.weblate.url = "github:WeblateOrg/weblate/weblate-4.9.1";
  inputs.weblate.flake = false;
  inputs.aeidon-src.url = "github:otsaloma/gaupol/1.9";
  inputs.aeidon-src.flake = false;

  outputs = { self, nixpkgs, poetry2nix, weblate, aeidon-src }:
    let
      pkgs = import nixpkgs {
        system = "x86_64-linux";
        overlays = [ poetry2nix.overlay ];
      };
    in
    {

      packages.x86_64-linux.weblate = (pkgs.poetry2nix.mkPoetryApplication {
        src = weblate;
        pyproject = ./pyproject.toml;
        poetrylock = ./poetry.lock;
        # The default timeout for the celery check is much too short upstream, so
        # we increase it. I guess this is due to the fact that we test the setup
        # very early into the initialization of the server, so the load might be
        # higher compared to production setups?
        patches = [ ./longer-celery-wait-time.patch ];
        meta = with pkgs.lib; {
          description = "Web based translation tool with tight version control integration";
          homepage = https://weblate.org/;
          license = licenses.gpl3Plus;
          maintainers = with maintainers; [ erictapen ];
        };
        overrides = pkgs.poetry2nix.overrides.withDefaults (
          self: super: {
            aeidon = super.aeidon.overridePythonAttrs (old: {
              src = aeidon-src;
              nativeBuildInputs = [ pkgs.gettext ];
              buildInputs = [ pkgs.isocodes ];
              installPhase = ''
                ${self.python.interpreter} setup.py --without-gaupol install --prefix=$out
              '';
            });
            # Copied from https://github.com/nix-community/poetry2nix/issues/413
            cryptography = super.cryptography.overridePythonAttrs (old: {
              cargoDeps = pkgs.rustPlatform.fetchCargoTarball {
                inherit (old) src;
                name = "${old.pname}-${old.version}";
                sourceRoot = "${old.pname}-${old.version}/src/rust/";
                # Remember to update this for new cryptography versions.
                sha256 = "sha256-tQoQfo+TAoqAea86YFxyj/LNQCiViu5ij/3wj7ZnYLI=";
              };
              cargoRoot = "src/rust";
              nativeBuildInputs = old.nativeBuildInputs ++ (with pkgs.rustPlatform; [
                rust.rustc
                rust.cargo
                cargoSetupHook
              ]);
            });
          }
        );
      }).dependencyEnv;

      defaultPackage.x86_64-linux = self.packages.x86_64-linux.weblate;

      nixosModules.weblate = import ./module.nix;

      overlay = final: prev: {
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
        pkgsWeblate.nixosTest (import ./integration-test.nix {
          inherit nixpkgs;
          weblateModule = self.nixosModules.weblate;
        });
      checks.x86_64-linux.package = self.defaultPackage.x86_64-linux;

    };
}
