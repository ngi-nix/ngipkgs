{
  ...
}:
finalMixPkgs: previousMixPkgs: {
  bonfire_federate_activitypub =
    previousMixPkgs.bonfire_federate_activitypub.overrideAttrs
      (previousAttrs: {
        # Explanation: missing dependency in upstream's deps.git…
        postPatch = previousAttrs.postPatch or "" + ''
          cat >>deps.git <<EOF

          bonfire_ui_common = "https://github.com/bonfire-networks/bonfire_ui_common"
          EOF
        '';
      });
}
