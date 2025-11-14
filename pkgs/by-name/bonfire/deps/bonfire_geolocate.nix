{
  fetchYarnDeps,
  stdenv,
  lib,
  #yarnBuildHook,
  yarnConfigHook,
  yarnInstallHook,
  ...
}:
let
  pname = "bonfire_geolocate";
in
finalMixPkgs: previousMixPkgs: {
  ${pname} = previousMixPkgs.${pname}.overrideAttrs (
    finalAttrs: previousAttrs: {
      passthru = {
        yarnOfflineCache = fetchYarnDeps {
          name = "${finalAttrs.name}-yarn-deps";
          yarnLock = "${finalAttrs.src}/assets/yarn.lock";
          hash = lib.readFile (./. + "/${pname}/yarnOfflineCache.hash");
        };
      };
    }
  );
}
