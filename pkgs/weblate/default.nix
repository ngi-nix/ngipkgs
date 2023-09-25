{
  lib,
  openssl,
  stdenv,
  leptonica,
  pkg-config,
  tesseract,
  buildPackages,
  maturin,
  rustPlatform,
  gettext,
  isocodes,
  poetry2nix,
  postgresql,
  fetchFromGitHub,
  ...
}:
poetry2nix.mkPoetryApplication rec {
  name = "weblate";
  version = "5.0.2";

  src = fetchFromGitHub {
    owner = "WeblateOrg";
    repo = "weblate";
    rev = "weblate-${version}";
  };

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
  meta = with lib; {
    description = "Web based translation tool with tight version control integration";
    homepage = "https://weblate.org/";
    license = licenses.gpl3Plus;
    maintainers = with maintainers; [erictapen];
  };
  overrides = poetry2nix.overrides.withDefaults (
    self: super: {
      aeidon = super.aeidon.overridePythonAttrs (old: {
        src = fetchFromGitHub {
          owner = "otasaloma";
          repo = "gaupol";
          rev = "1.12";
        };
        nativeBuildInputs = [gettext self.flake8];
        buildInputs = [isocodes];
        installPhase = ''
          ${self.python.interpreter} setup.py --without-gaupol install --prefix=$out
        '';
      });
      fluent-syntax = super.fluent-syntax.overridePythonAttrs (old: {
        nativeBuildInputs = (old.nativeBuildInputs or []) ++ [self.setuptools];
      });
      phply = super.phply.overridePythonAttrs (old: {
        nativeBuildInputs = (old.nativeBuildInputs or []) ++ [self.setuptools];
      });
      pycairo = super.pycairo.overridePythonAttrs (old: {
        # See: https://discourse.nixos.org/t/nix-flake-direnv-fails-to-build-pycairo/26639/6
        nativeBuildInputs = [self.meson buildPackages.pkg-config];
      });
      pygobject = super.pygobject.overridePythonAttrs (old: {
        nativeBuildInputs = (old.nativeBuildInputs or []) ++ [self.setuptools];
      });
      pyicumessageformat = super.pyicumessageformat.overridePythonAttrs (old: {
        nativeBuildInputs = (old.nativeBuildInputs or []) ++ [self.setuptools];
      });
      borgbackup = super.borgbackup.overridePythonAttrs (old: {
        nativeBuildInputs = (old.nativeBuildInputs or []) ++ [self.setuptools-scm];
      });
      siphashc = super.siphashc.overridePythonAttrs (old: {
        nativeBuildInputs = (old.nativeBuildInputs or []) ++ [self.setuptools];
      });
      translate-toolkit = super.translate-toolkit.overridePythonAttrs (old: {
        nativeBuildInputs = (old.nativeBuildInputs or []) ++ [self.setuptools];
      });
      weblate-language-data = super.weblate-language-data.overridePythonAttrs (old: {
        nativeBuildInputs = (old.nativeBuildInputs or []) ++ [self.setuptools];
      });
      translation-finder = super.translation-finder.overridePythonAttrs (old: {
        nativeBuildInputs = (old.nativeBuildInputs or []) ++ [self.setuptools];
      });
      weblate-schemas = super.weblate-schemas.overridePythonAttrs (old: {
        nativeBuildInputs = (old.nativeBuildInputs or []) ++ [self.setuptools];
      });
      diff-match-patch = super.diff-match-patch.overridePythonAttrs (old: {
        nativeBuildInputs = (old.nativeBuildInputs or []) ++ [self.flit-core];
      });
      editables = super.editables.overridePythonAttrs (old: {
        nativeBuildInputs = (old.nativeBuildInputs or []) ++ [self.flit-core];
      });
      nh3 = super.nh3.overridePythonAttrs (old: {
        nativeBuildInputs =
          (old.nativeBuildInputs or [])
          ++ [
            maturin
            rustPlatform.maturinBuildHook
            rustPlatform.cargoSetupHook
          ];
        cargoDeps = let
          getCargoHash = version:
            {
              "0.2.14" = "sha256-EzlwSic1Qgs4NZAde/KWg0Qjs+PNEPcnE8HyIPoYZQ0=";
            }
            .${version};
        in
          rustPlatform.fetchCargoTarball {
            inherit (old) src;
            name = "${old.pname}-${old.version}";
            hash = getCargoHash old.version;
          };
      });
      crispy-bootstrap3 = super.crispy-bootstrap3.overridePythonAttrs (old: {
        nativeBuildInputs = (old.nativeBuildInputs or []) ++ [self.setuptools];
      });
      psycopg = super.psycopg.overridePythonAttrs (
        old: {
          buildInputs =
            (old.buildInputs or [])
            ++ lib.optional stdenv.isDarwin openssl;
          nativeBuildInputs = (old.nativeBuildInputs or []) ++ [postgresql];
        }
      );
      tesserocr = super.tesserocr.overridePythonAttrs (
        old: {
          buildInputs = (old.buildInputs or []) ++ [leptonica tesseract];
          nativeBuildInputs = (old.nativeBuildInputs or []) ++ [pkg-config];
        }
      );
      ahocorasick-rs = super.ahocorasick-rs.overridePythonAttrs (
        old: {
          nativeBuildInputs =
            (old.nativeBuildInputs or [])
            ++ [
              rustPlatform.maturinBuildHook
              rustPlatform.cargoSetupHook
            ];
          cargoDeps = rustPlatform.fetchCargoTarball {
            inherit (old) src;
            name = "${old.pname}-${old.version}";
            hash = "sha256-/sel54PV58y6oUgIzHXSCL4RMljPL9kZ6ER/pRTAjAI=";
          };
        }
      );
    }
  );
}
