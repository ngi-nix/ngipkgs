{
  fetchYarnDeps,
  stdenv,
  lib,
  yarnConfigHook,
  yarnInstallHook,
  ...
}:
let
  pname = "bonfire_geolocate";
in
finalMixPkgs: previousMixPkgs: {
  ${pname} =
    (previousMixPkgs.${pname} or (stdenv.mkDerivation { name = "${pname}-dummy"; })).overrideAttrs
      (
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
