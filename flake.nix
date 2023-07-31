{
  description = "Weblate package and module";

  inputs.nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
  inputs.poetry2nix.url = "github:nix-community/poetry2nix/master";
  inputs.poetry2nix.inputs.nixpkgs.follows = "nixpkgs";
  inputs.weblate.url = "github:WeblateOrg/weblate/weblate-4.18.2";
  inputs.weblate.flake = false;
  inputs.aeidon-src.url = "github:otsaloma/gaupol/1.12";
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
            phply = super.phply.overridePythonAttrs (old: {
              nativeBuildInputs = (old.nativeBuildInputs or [ ]) ++ [ self.setuptools ];
            });
            pycairo = super.pycairo.overridePythonAttrs (old: {
              # See: https://discourse.nixos.org/t/nix-flake-direnv-fails-to-build-pycairo/26639/6
              nativeBuildInputs = [ self.meson pkgs.buildPackages.pkg-config ];
            });
            pygobject = super.pygobject.overridePythonAttrs (old: {
              nativeBuildInputs = (old.nativeBuildInputs or [ ]) ++ [ self.setuptools ];
            });
            pyicumessageformat = super.pyicumessageformat.overridePythonAttrs (old: {
              nativeBuildInputs = (old.nativeBuildInputs or [ ]) ++ [ self.setuptools ];
            });
            borgbackup = super.borgbackup.overridePythonAttrs (old: {
              nativeBuildInputs = (old.nativeBuildInputs or [ ]) ++ [ self.setuptools-scm ];
            });
            siphashc = super.siphashc.overridePythonAttrs (old: {
              nativeBuildInputs = (old.nativeBuildInputs or [ ]) ++ [ self.setuptools ];
            });
            translate-toolkit = super.translate-toolkit.overridePythonAttrs (old: {
              nativeBuildInputs = (old.nativeBuildInputs or [ ]) ++ [ self.setuptools ];
            });
            pillow = super.pillow.override {
              preferWheel = true;
            };
            weblate-language-data = super.weblate-language-data.overridePythonAttrs (old: {
              nativeBuildInputs = (old.nativeBuildInputs or [ ]) ++ [ self.setuptools ];
            });
            translation-finder = super.translation-finder.overridePythonAttrs (old: {
              nativeBuildInputs = (old.nativeBuildInputs or [ ]) ++ [ self.setuptools ];
            });
            weblate-schemas = super.weblate-schemas.overridePythonAttrs (old: {
              nativeBuildInputs = (old.nativeBuildInputs or [ ]) ++ [ self.setuptools ];
            });
            diff-match-patch = super.diff-match-patch.overridePythonAttrs (old: {
              nativeBuildInputs = (old.nativeBuildInputs or [ ]) ++ [ self.flit-core ];
            });
            editables = super.editables.overridePythonAttrs (old: {
              nativeBuildInputs = (old.nativeBuildInputs or [ ]) ++ [ self.flit-core ];
            });
            nh3 = super.nh3.overridePythonAttrs (old: {
              nativeBuildInputs = (old.nativeBuildInputs or [ ]) ++ [
                pkgs.maturin
                pkgs.rustPlatform.maturinBuildHook
                pkgs.rustPlatform.cargoSetupHook
              ];
              cargoDeps =
                let
                  getCargoHash = version: {
                    "0.2.14" = "sha256-EzlwSic1Qgs4NZAde/KWg0Qjs+PNEPcnE8HyIPoYZQ0=";
                  }.${version};
                in
                pkgs.rustPlatform.fetchCargoTarball {
                  inherit (old) src;
                  name = "${old.pname}-${old.version}";
                  hash = getCargoHash old.version;
                };
            });
            crispy-bootstrap3 = super.crispy-bootstrap3.overridePythonAttrs (old: {
              nativeBuildInputs = (old.nativeBuildInputs or [ ]) ++ [ self.setuptools ];
            });
            psycopg = super.psycopg.overridePythonAttrs (
              old: {
                buildInputs = (old.buildInputs or [ ])
                  ++ pkgs.lib.optional pkgs.stdenv.isDarwin pkgs.openssl;
                nativeBuildInputs = (old.nativeBuildInputs or [ ]) ++ [ pkgs.postgresql ];
              }
            );
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
