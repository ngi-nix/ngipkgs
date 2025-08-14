{
  lib,
  beamPackages,
  buildNpmPackage,
  cacert,
  fetchFromGitHub,
  fetchFromGitLab,
  nodejs,
}:
let
  # https://github.com/elixir-lang/elixir/issues/13976
  beamPackages' = beamPackages.extend (self: super: { elixir = self.elixir_1_17; });

  pname = "kazarma";
  version = "1.0.0-alpha.1-unstable-2025-06-30";
  src = fetchFromGitLab {
    group = "technostructures";
    owner = "kazarma";
    repo = "kazarma";
    rev = "2cd1ca80d3c54e54a11fd3b9079f6c4fa6330302";
    fetchSubmodules = true;
    hash = "sha256-Ry5xgGeVzzjnumlYXrU8vzvf1l7IeVfSL+RvGPmWq9U=";
  };

  cldr = fetchFromGitHub {
    owner = "elixir-cldr";
    repo = "cldr";
    tag = "v2.37.2";
    hash = "sha256-dDOQzLIi3zjb9xPyR7Baul96i9Mb3CFHUA+AWSexrk4=";
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
    hash = "sha256-APOzFj+3yFrpDV8U2bZCJwZC9iHGISeKcZUGS8d3mtA=";
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

  meta = {
    description = "Matrix bridge to ActivityPub";
    homepage = "https://kazar.ma/";
    downloadPage = "https://gitlab.com/technostructures/kazarma/kazarma";
    license = lib.licenses.agpl3Only;
    teams = [ lib.teams.ngi ];
    mainProgram = "kazarma";
  };
}
