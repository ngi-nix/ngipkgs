{
  lib,
  fetchYarnDeps,
  nodejs,
  stdenv,
  bonfireSetup,
  yarnBuildHook,
  yarnConfigHook,
  yarnInstallHook,
  tree,
  bonfire,
  ...
}:
let
  pname = "bonfire_ui_common";
in
finalMixPkgs: previousMixPkgs: {
  ${pname} = previousMixPkgs.${pname}.overrideAttrs (
    finalAttrs: previousAttrs: {
      postPatch =
        previousAttrs.postPatch or ""
        + lib.concatStringsSep "\n" [
          # Explanation: remove a dangling symlink pointing out of the repo…
          ''
            rm priv/static
          ''
        ];
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
