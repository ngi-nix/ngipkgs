{
  bundlerEnv,
  dart-sass,
  fetchFromGitHub,
  lib,
  libarchive,
  nodejs_22,
  ruby_3_4,
  stdenvNoCC,
  yarn-berry_3,
}:
let
  ruby = ruby_3_4;
  yarn-berry = yarn-berry_3;
  gems = bundlerEnv {
    name = "manyfold-env";
    inherit ruby;
    gemdir = ./.;
  };
in
stdenvNoCC.mkDerivation (finalAttrs: {
  pname = "manyfold";
  version = "0.122.1";

  src = fetchFromGitHub {
    owner = "manyfold3d";
    repo = "manyfold";
    tag = "v${finalAttrs.version}";
    hash = "sha256-rE54BKWYRwf2rtMWY1FgC/XFVT5ro1ppfa3HPKTEOMM=";
  };

  prePatch = ''
    echo ${lib.getVersion ruby} >.ruby-version
    substituteInPlace Gemfile.lock \
      --replace-fail 'ruby 3.4.1p0' 'ruby ${lib.getVersion ruby}'
  '';

  nativeBuildInputs = [
    nodejs_22
    ruby
    yarn-berry
    yarn-berry.yarnBerryConfigHook
  ];

  missingHashes = ./missing-hashes.json;
  offlineCache = yarn-berry.fetchYarnBerryDeps {
    inherit (finalAttrs) src missingHashes;
    hash = "sha256-JLUi1wKLccepaylFXKQovdo0rQixBDFtKeCw/cHi+qI=";
  };

  LD_LIBRARY_PATH = lib.makeLibraryPath [
    # needed at build time by ruby gem ffi-libarchive
    # https://github.com/chef/ffi-libarchive/blob/c0c3e3914d3c1ad30e7cf8dd93182bf5243ffe81/lib/ffi-libarchive/archive.rb#L14
    libarchive
  ];

  preBuild = ''
    mkdir -p vendor/bundle/ruby
    ln -s ${gems}/${ruby.gemPath} vendor/bundle/ruby/

    bundle config set deployment true

    # force sass-embedded to use our own sass instead of the bundled one
    substituteInPlace node_modules/sass-embedded/dist/lib/src/compiler-path.js \
        --replace-fail 'compilerCommand = (() => {' 'compilerCommand = (() => { return ["${lib.getExe dart-sass}"];'
  '';

  buildPhase = ''
    runHook preBuild

    # https://github.com/manyfold3d/manyfold/blob/v0.122.1/docker/build.dockerfile#L35-L40
    export DATABASE_URL="nulldb://user:pass@localhost/db"
    export SECRET_KEY_BASE="placeholder"
    export RACK_ENV="production"
    export RAILS_ASSETS_PRECOMPILE=1

    bundle exec rake assets:precompile

    runHook postBuild
  '';

  installPhase = ''
    runHook preInstall
    mkdir -p $out/lib/manyfold
    cp -r . $out/lib/manyfold/
    runHook postInstall
  '';

  meta = {
    description = "ActivityPub-powered tool for storing and sharing 3d models";
    homepage = "https://manyfold.app/";
    downloadPage = "https://github.com/manyfold3d/manyfold";
    license = lib.licenses.mit;
    teams = [ lib.teams.ngi ];
  };
})
