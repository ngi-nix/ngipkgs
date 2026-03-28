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
  version = "4.10.1";

  src = fetchFromGitHub {
    owner = "NodeBB";
    repo = "NodeBB";
    tag = "v${finalAttrs.version}";
    hash = "sha256-QG55il+BeVdfmKrOvsyjULHUpySiYrWvgblO8OPsKM0=";
    postFetch = ''
      cp $out/install/package.json $out
    '';
  };

  patches = [
    # sharp is failing to build from source
    # node-gyp is missing from the install/package.json
    ./0001-add-node-gyp-to-dependencies.patch
  ];

  postPatch = ''
    cp ${./package-lock.json} ./package-lock.json

    # overrwrite the package.json to the patched version
    cp install/package.json package.json
  '';

  npmDepsHash = "sha256-o6waZ/LmvJ7fLpQk8Te4X6atV0wAABWyU7XOC4gxLjk=";

  makeCacheWritable = true;

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
