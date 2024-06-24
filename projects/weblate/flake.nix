{
  description = "Weblate package and module";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/9693852a2070b398ee123a329e68f0dab5526681";
    flake-utils.url = "github:numtide/flake-utils";
    poetry2nix.url = "github:nix-community/poetry2nix";
    poetry2nix.inputs.nixpkgs.follows = "nixpkgs";
    weblate.url = "github:WeblateOrg/weblate/weblate-5.6.1";
    weblate.flake = false;
    aeidon-src.url = "github:otsaloma/gaupol/1.12";
    aeidon-src.flake = false;
  };

  outputs = { self, nixpkgs, flake-utils, weblate, aeidon-src, poetry2nix }:
    let
      systems = [ "x86_64-linux" "aarch64-linux" ];
      inherit (flake-utils.lib) eachSystem;
    in
    eachSystem systems
      (system:
        let
          pkgs = nixpkgs.legacyPackages.${system};
          poetry2nix_instanciated = poetry2nix.lib.mkPoetry2Nix { inherit pkgs; };
        in
        {

          packages =
            {
              default = self.packages.${system}.weblate;
              weblate = poetry2nix_instanciated.mkPoetryApplication {
                description = "";
                src = weblate;
                pyproject = ./pyproject.toml;
                poetrylock = ./poetry.lock;
                patches = [
                  # The default timeout for the celery check is much too short upstream, so
                  # we increase it. I guess this is due to the fact that we test the setup
                  # very early into the initialization of the server, so the load might be
                  # higher compared to production setups?
                  ./longer-celery-wait-time.patch
                  # FIXME This shouldn't be necessary and probably has to do with some dependency mismatch.
                  ./cache.lock.patch
                ];
                meta = with pkgs.lib; {
                  description = "Web based translation tool with tight version control integration";
                  homepage = "https://weblate.org/";
                  license = licenses.gpl3Plus;
                  maintainers = with maintainers; [ erictapen ];
                };
                overrides = poetry2nix_instanciated.overrides.withDefaults (
                  self: super: {
                    aeidon = super.aeidon.overridePythonAttrs (old: {
                      src = aeidon-src;
                      nativeBuildInputs = [ pkgs.gettext self.flake8 ];
                      buildInputs = [ pkgs.isocodes ];
                      installPhase = ''
                        ${self.python.interpreter} setup.py --without-gaupol install --prefix=$out
                      '';
                    });
                    fluent-syntax = super.fluent-syntax.overridePythonAttrs (old: {
                      nativeBuildInputs = (old.nativeBuildInputs or [ ]) ++ [ self.setuptools ];
                    });
                    phply = super.phply.overridePythonAttrs (old: {
                      nativeBuildInputs = (old.nativeBuildInputs or [ ]) ++ [ self.setuptools ];
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
                    tesserocr = super.tesserocr.overridePythonAttrs (
                      old: {
                        buildInputs = (old.buildInputs or [ ]) ++ [ pkgs.leptonica pkgs.tesseract ];
                        nativeBuildInputs = (old.nativeBuildInputs or [ ]) ++ [ pkgs.pkg-config ];
                      }
                    );
                    ahocorasick-rs = super.ahocorasick-rs.overridePythonAttrs (
                      old: {
                        nativeBuildInputs = (old.nativeBuildInputs or [ ]) ++ [
                          pkgs.rustPlatform.maturinBuildHook
                          pkgs.rustPlatform.cargoSetupHook

                        ];
                        cargoDeps = pkgs.rustPlatform.fetchCargoTarball {
                          inherit (old) src;
                          name = "${old.pname}-${old.version}";
                          hash = "sha256-/sel54PV58y6oUgIzHXSCL4RMljPL9kZ6ER/pRTAjAI=";
                        };

                      }
                    );
                  }
                );
              };
            };

          checks = {
            integrationTest =
              let
                # As pkgs doesn't contain the weblate package and module, we have to
                # evaluate Nixpkgs again.
                pkgsWeblate = import nixpkgs {
                  inherit system;
                  overlays = [ self.overlays.default ];
                };
              in
              pkgsWeblate.nixosTest (import ./integration-test.nix {
                inherit nixpkgs;
                weblateModule = self.nixosModules.weblate;
              });
            package = self.packages.${system}.weblate;
          };

        }) // {

      nixosModules.weblate = import ./module.nix;

      overlays.default = final: prev: {
        inherit (self.packages.${prev.system}) weblate;
      };
    };
}
