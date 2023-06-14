{
  description = "Weblate package and module";

  inputs.nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
  inputs.poetry2nix.url = "github:nix-community/poetry2nix/master";
  inputs.poetry2nix.inputs.nixpkgs.follows = "nixpkgs";
  inputs.weblate.url = "github:WeblateOrg/weblate/weblate-4.14.1";
  inputs.weblate.flake = false;
  inputs.aeidon-src.url = "github:otsaloma/gaupol/1.11";
  inputs.aeidon-src.flake = false;

  outputs = { self, nixpkgs, weblate, aeidon-src, poetry2nix }:
    let
      pkgs = import nixpkgs {
        system = "x86_64-linux";
        overlays = [ poetry2nix.overlay ];
      };
    in
    {

      packages.x86_64-linux.default = self.packages.x86_64-linux.weblate;
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
              nativeBuildInputs = [ pkgs.gettext self.flake8 ];
              buildInputs = [ pkgs.isocodes ];
              installPhase = ''
                ${self.python.interpreter} setup.py --without-gaupol install --prefix=$out
              '';
            });
            click-didyoumean = super.click-didyoumean.overridePythonAttrs (old: {
              nativeBuildInputs = (old.nativeBuildInputs or [ ]) ++ [ self.poetry ];
            });
            pyparsing = super.pyparsing.overridePythonAttrs (old: {
              nativeBuildInputs = (old.nativeBuildInputs or [ ]) ++ [ self.flit-core ];
            });
            ua-parser = super.ua-parser.overridePythonAttrs (old: {
              nativeBuildInputs = (old.nativeBuildInputs or [ ]) ++ [ self.pyyaml ];
              postPatch = ''
                substituteInPlace setup.py \
                  --replace "pyyaml ~= 5.4.0" "pyyaml~=6.0"
              '';
            });
            jarowinkler = super.jarowinkler.overridePythonAttrs (old: {
              nativeBuildInputs = (old.nativeBuildInputs or [ ]) ++ [ self.scikit-build ];
            });
            rapidfuzz = super.rapidfuzz.overridePythonAttrs (old: {
              nativeBuildInputs = (old.nativeBuildInputs or [ ]) ++ [ self.scikit-build ];
            });
            jsonschema = super.jsonschema.overridePythonAttrs (old: {
              nativeBuildInputs = (old.nativeBuildInputs or [ ]) ++ [ self.hatch-fancy-pypi-readme ];
            });
            fluent-syntax = super.fluent-syntax.overridePythonAttrs (old: {
              nativeBuildInputs = (old.nativeBuildInputs or [ ]) ++ [ self.setuptools ];
            });
          }
        );
      }).dependencyEnv;

      nixosModules.weblate = import ./module.nix;

      overlays.default = final: prev: {
        inherit (self.packages.x86_64-linux) weblate;
      };

      checks.x86_64-linux.integrationTest =
        let
          # As pkgs doesn't contain the weblate package and module, we have to
          # evaluate Nixpkgs again.
          pkgsWeblate = import nixpkgs {
            system = "x86_64-linux";
            overlays = [ self.overlays.default ];
          };
        in
        pkgsWeblate.nixosTest (import ./integration-test.nix {
          inherit nixpkgs;
          weblateModule = self.nixosModules.weblate;
        });
      checks.x86_64-linux.package = self.packages.x86_64-linux.weblate;

    };
}
