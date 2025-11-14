{
  ...
}:
finalMixPkgs: previousMixPkgs: {
  bonfire_ui_me = previousMixPkgs.bonfire_ui_me.overrideAttrs (previousAttrs: {
    # Explanation: missing dependency in upstream's deps.hex…
    postPatch = previousAttrs.postPatch or "" + ''
      cat >>deps.hex <<EOF

      absinthe_phoenix = ">= 0.0.0"
      EOF
    '';
  });
}
