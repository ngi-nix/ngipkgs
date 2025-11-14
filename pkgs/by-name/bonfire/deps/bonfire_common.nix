{
  ...
}:
finalMixPkgs: previousMixPkgs: {
  bonfire_common = previousMixPkgs.bonfire_common.overrideAttrs (previousAttrs: {
    # Explanation: remove a dangling symlink pointing out of bonfire_common…
    postPatch = previousAttrs.postPatch or "" + ''
      rm priv/localisation
    '';
  });
}
