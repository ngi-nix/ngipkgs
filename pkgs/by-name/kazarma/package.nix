{
  lib,
  beam27Packages,
  buildNpmPackage,
  cacert,
  fetchFromGitHub,
  fetchFromGitLab,
  nodejs,
  _experimental-update-script-combinators,
  unstableGitUpdater,
  nix-update-script,
}:
let
  beamPackages = beam27Packages;

  # https://github.com/elixir-lang/elixir/issues/13976
  beamPackages' = beamPackages.extend (self: super: { elixir = self.elixir_1_17; });

  pname = "kazarma";
  version = "1.0.0-alpha.1-unstable-2025-12-24";
  src = fetchFromGitLab {
    group = "technostructures";
    owner = "kazarma";
    repo = "kazarma";
    rev = "46dbc8d29006896b6b14057c1d0feb39bd768865";
    fetchSubmodules = true;
    hash = "sha256-N8JP9I35sMxOj5BPIrwsfMb+puL9GXwdksnJR5CDcwg=";
  };

  cldr = fetchFromGitHub {
    owner = "elixir-cldr";
    repo = "cldr";
    tag = "v2.43.2";
    hash = "sha256-xSWZV4bDcy/P5sSDM7gvuaCLhk4bk3lL2/MB5cm5/PE=";
  };

  assets = buildNpmPackage (finalAttrs: {
    pname = "${pname}-assets";
    inherit version src;
    sourceRoot = "${finalAttrs.src.name}/assets";
    patches = [ ./assets.patch ];
    npmDepsHash = "sha256-ygMFzDkl83cDh+72xuf/PyOBxIax2d58OSP+eeG+Na0=";
    npmFlags = [ "--include=dev" ];
    dontNpmBuild = true;
    dontCheckForBrokenSymlinks = true;
  });
in
beamPackages'.mixRelease {
  inherit pname version src;

  mixFodDeps = beamPackages'.fetchMixDeps {
    pname = "mix-deps-${pname}";
    inherit version src;
    hash = "sha256-nsTAsVoDPmKQVjybaTDu18UGtqsvBz/A5mzzLKBqAHY=";
  };

  nativeBuildInputs = [
    cacert
    nodejs
  ];

  patches = [
    ./cacert.patch
    ./cldr-data_dir.patch
    ./tzdata.patch
    ./matrix_domain.patch
  ];

  preConfigure = ''
    rm -r deps
  '';

  preBuild = ''
    mkdir -p cldr
    ln -s ${cldr}/priv/cldr/locales cldr/
  '';

  postBuild = ''
    rm -r assets
    cp -r ${assets}/lib/node_modules/assets .
    npm run deploy --prefix ./assets
    mix do deps.loadpaths --no-deps-check, phx.digest
  '';

  # Can't update from GitLab with fetchSubmodules
  # https://github.com/Mic92/nix-update/issues/281
  # TODO: also update `cldr`, if necessary
  passthru.updateScript = _experimental-update-script-combinators.sequence [
    (unstableGitUpdater { tagPrefix = "v"; }) # update version + source
    (nix-update-script { extraArgs = [ "--version=skip" ]; }) # update deps
  ];

  meta = {
    description = "Matrix bridge to ActivityPub";
    homepage = "https://kazar.ma/";
    downloadPage = "https://gitlab.com/technostructures/kazarma/kazarma";
    license = lib.licenses.agpl3Only;
    teams = [ lib.teams.ngi ];
    mainProgram = "kazarma";
  };
}
