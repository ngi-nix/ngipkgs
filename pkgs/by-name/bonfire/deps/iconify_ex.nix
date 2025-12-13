{
  fetchYarnDeps,
  lib,
  ...
}:
let
  pname = "iconify_ex";
in
finalMixPkgs: previousMixPkgs: {
  ${pname} = previousMixPkgs.${pname}.overrideAttrs (
    finalAttrs: previousAttrs: {
      # Explanation: make iconify.ex look for its assets
      # in $out/assets/… instead of /build/source/assets/….
      postPatch = previousAttrs.postPatch or "" + ''
        substituteInPlace lib/iconify.ex \
          --replace-fail 'File.cwd!()' "\"$out\""
      '';
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
