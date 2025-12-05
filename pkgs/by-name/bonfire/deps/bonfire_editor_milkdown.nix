{
  fetchYarnDeps,
  lib,
  ...
}:
let
  pname = "bonfire_editor_milkdown";
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
