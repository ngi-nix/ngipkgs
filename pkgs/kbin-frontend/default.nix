{
  lib,
  kbin,
  mkYarnPackage,
  fetchYarnDeps,
}:
mkYarnPackage rec {
  inherit (kbin) version src;

  pname = "${kbin.pname}-frontend";

  offlineCache = fetchYarnDeps {
    yarnLock = "${src}/yarn.lock";
    hash = "sha256-mH5E5WjEzrC+UL4yk9hwRYD1J81+hLgjHb7poPWuiFQ=";
  };

  packageResolutions = builtins.listToAttrs (builtins.map (package: {
    name = "@symfony/${package}";
    value = "${kbin}/share/php/kbin/vendor/symfony/${package}/assets";
  }) ["stimulus-bundle" "ux-autocomplete" "ux-chartjs"]);

  buildPhase = ''
    mkdir -p deps/${pname}/vendor/friendsofsymfony/jsrouting-bundle/Resources
    cp -r ${kbin}/share/php/kbin/vendor/friendsofsymfony/jsrouting-bundle/Resources/public \
      deps/${pname}/vendor/friendsofsymfony/jsrouting-bundle/Resources

    yarn --offline build
  '';

  installPhase = ''
    mkdir -p $out/share/php/kbin
    # FIXME
    cp -r ${kbin}/share/php/kbin $out/share/php
    # FIXME
    chmod -R 777 $out/share
    # cp -r deps/${pname}/public/build/* $out
    cp -r deps/${pname}/* $out/share/php/kbin

    mkdir $out/share/php/kbin/public/media
  '';

  distPhase = "true";
}
