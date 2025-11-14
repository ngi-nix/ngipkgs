{
  ...
}:
finalMixPkgs: previousMixPkgs: {
  bonfire_data_access_control =
    (previousMixPkgs.bonfire_data_access_control.override (previousArgs: {
      beamDeps =
        previousArgs.beamDeps
        ++ (with finalMixPkgs; [
          # Explanation: missing dependency in upstream deps.hex…
          typed_ecto_schema
        ]);
    })).overrideAttrs
      (previousAttrs: {
        postPatch = previousAttrs.postPatch or "" + ''
          cat >>deps.hex <<EOF

          typed_ecto_schema = ">= 0.0.0"
          EOF
        '';
      });
}
