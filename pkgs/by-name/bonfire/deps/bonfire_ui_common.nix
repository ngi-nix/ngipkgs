{
  ...
}:
finalMixPkgs: previousMixPkgs: {
  bonfire_ui_common = previousMixPkgs.bonfire_ui_common.overrideAttrs (previousAttrs: {
    # Explanation: remove a dangling symlink pointing out of bonfire_ui_common…
    postPatch = previousAttrs.postPatch or "" + ''
      rm priv/static
    '';
    # Explanation: buildMix copies $src into $out/src,
    # so the dangling symlink has to be removed from there too.
    postInstall = previousAttrs.postInstall or "" + ''
      chmod u+w $out/src/priv
      rm $out/src/priv/static
    '';
  });
}
