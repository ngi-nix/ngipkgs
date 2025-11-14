{
  ...
}:
finalMixPkgs: previousMixPkgs: {
  bonfire_common = previousMixPkgs.bonfire_common.overrideAttrs (previousAttrs: {
    # Explanation: remove a dangling symlink pointing out of bonfire_common…
    # And somehow bypass the force_locale_download set in config/bonfire_common.exs
    postPatch = previousAttrs.postPatch or "" + ''
      rm priv/localisation
    '';
  });
}
