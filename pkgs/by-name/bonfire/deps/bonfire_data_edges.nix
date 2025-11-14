{
  ...
}:
finalMixPkgs: previousMixPkgs: {
  bonfire_data_edges = previousMixPkgs.bonfire_data_edges.overrideAttrs (previousAttrs: {
    # Explanation: missing transitive dependency in upstream's deps.hex…
    postPatch = previousAttrs.postPatch or "" + ''
      cat >>deps.hex <<EOF

      typed_ecto_schema = ">= 0.0.0"
      EOF
    '';
  });
}
