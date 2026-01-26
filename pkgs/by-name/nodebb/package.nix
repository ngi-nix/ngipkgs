{
  lib,
  buildNpmPackage,
  fetchFromGitHub,
  pkg-config,
  dart-sass,
  vips,
  node-gyp,
  nix-update-script,
}:

buildNpmPackage (finalAttrs: {
  pname = "nodebb";
  version = "4.8.0";

  src = fetchFromGitHub {
    owner = "NodeBB";
    repo = "NodeBB";
    tag = "v${finalAttrs.version}";
    hash = "sha256-eBsRS1wO5E1ulzrjxcz/7eUUCkDNEC1wrOZpe04v/HU=";
    postFetch = ''
      cp $out/install/package.json $out
    '';
  };

  postPatch = ''
    cp ${./package-lock.json} ./package-lock.json
  '';

  npmDepsHash = "sha256-YT5MOGEgL5CdwE5ENX8UgKZGX0FjqOkKrcKgBb/kUak=";

  nativeBuildInputs = [ pkg-config ];

  buildInputs = [
    dart-sass
    vips
    node-gyp
  ];

  buildPhase = ''
    runHook preBuild

    # force sass-embedded to use our own sass instead of the bundled one
    substituteInPlace node_modules/sass-embedded/dist/lib/src/compiler-path.js \
        --replace-fail 'compilerCommand = (() => {' 'compilerCommand = (() => { return ["${lib.getExe dart-sass}"];'

    runHook postBuild
  '';

  # FIX: this doesn't update npmDepsHash automatically
  passthru.updateScript = nix-update-script { extraArgs = [ "--generate-lockfile" ]; };

  meta = {
    description = "Forum software";
    homepage = "https://nodebb.org/";
    license = lib.licenses.gpl3Plus;
    maintainers = with lib.maintainers; [ prince213 ];
    teams = with lib.teams; [ ngi ];
    platforms = lib.platforms.all;
  };
})
