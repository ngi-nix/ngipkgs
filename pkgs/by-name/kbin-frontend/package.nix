{
  lib,
  kbin-backend,
  mkYarnPackage,
  fetchYarnDeps,
}:
mkYarnPackage rec {
  inherit (kbin-backend) version src passthru;

  pname = "${kbin-backend.pname}-frontend";

  packageJSON = ./package.json;

  offlineCache = fetchYarnDeps {
    yarnLock = "${src}/yarn.lock";
    hash = "sha256-mH5E5WjEzrC+UL4yk9hwRYD1J81+hLgjHb7poPWuiFQ=";
  };

  packageResolutions = builtins.listToAttrs (
    builtins.map
      (package: {
        name = "@symfony/${package}";
        value = "${kbin-backend}/share/php/kbin/vendor/symfony/${package}/assets";
      })
      [
        "stimulus-bundle"
        "ux-autocomplete"
        "ux-chartjs"
      ]
  );

  buildPhase = ''
    mkdir -p deps/${pname}/vendor/friendsofsymfony/jsrouting-bundle/Resources
    cp -r ${kbin-backend}/share/php/kbin/vendor/friendsofsymfony/jsrouting-bundle/Resources/public \
      deps/${pname}/vendor/friendsofsymfony/jsrouting-bundle/Resources

    yarn --offline build
  '';

  installPhase = ''
    mkdir $out
    cp -r deps/${pname}/public/build/* $out
  '';

  distPhase = "true";
}
