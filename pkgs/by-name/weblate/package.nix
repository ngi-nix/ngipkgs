{
  stdenv,
  lib,
  fetchFromGitHub,
  poetry2nix,
  pkg-config,
  openssl,
  isocodes,
  gettext,
  maturin,
  rustPlatform,
  postgresql,
  leptonica,
  tesseract,
  gobject-introspection,
  wrapGAppsNoGuiHook,
  pango,
  harfbuzz,
  librsvg,
  gdk-pixbuf,
}:
poetry2nix.mkPoetryApplication {
  src = fetchFromGitHub {
    owner = "WeblateOrg";
    repo = "weblate";
    rev = "weblate-5.6.2";
    sha256 = "sha256-t/hnigsKjdWCkUd8acNWhYVFmZ7oGn74+12347MkFgM=";
  };

  pyproject = ./pyproject.toml;
  poetrylock = ./poetry.lock;

  patches = [
    # FIXME This shouldn't be necessary and probably has to do with some dependency mismatch.
    ./cache.lock.patch
  ];

  makeWrapperArgs = [
    "\${gappsWrapperArgs[@]}"
  ];

  nativeBuildInputs = [
    wrapGAppsNoGuiHook
    gobject-introspection
  ];

  dontWrapGApps = true;

  overrides = poetry2nix.overrides.withDefaults (
    self: super: {
      aeidon = super.aeidon.overridePythonAttrs (old: {
        src = fetchFromGitHub {
          owner = "otsaloma";
          repo = "gaupol";
          rev = "1.15";
          sha256 = "sha256-lhNyeieeiBBm3rNDEU0BuWKeM6XYlOtv1voW8tR8cUM=";
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
              "0.2.17" = "sha256-WomlVzKOUfcgAWGJInSvZn9hm+bFpgc4nJbRiyPCU64=";
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
            hash = "sha256-CIt/ChNcoqKln6PgeTGp9pfmIWlJj+c5SCPtBhsnT6U=";
          };
        }
      );
    }
  );

  meta = with lib; {
    description = "Web based translation tool with tight version control integration";
    homepage = "https://weblate.org/";
    license = licenses.gpl3Plus;
    maintainers = with maintainers; [erictapen];
  };
}
