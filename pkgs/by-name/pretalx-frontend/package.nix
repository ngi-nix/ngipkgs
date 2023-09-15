{
  buildNpmPackage,
  pretalx,
}:
buildNpmPackage {
  inherit (pretalx) version src meta;
  pname = "pretalx-frontend";

  sourceRoot = "source/src/pretalx/frontend/schedule-editor";

  npmDepsHash = "sha256-4cnBHZ8WpHgp/bbsYYbdtrhuD6ffUAZq9ZjoLpWGfRg=";

  buildPhase = ''
    runHook preBuild

    npm run build

    runHook postBuild
  '';
}
