{
  ...
}:
let
  pname = "bonfire_ui_me";
in
finalMixPkgs: previousMixPkgs: {
  ${pname} = previousMixPkgs.${pname}.overrideAttrs (previousAttrs: {
    # Explanation: missing dependency in upstream's deps.hex…
    postPatch = previousAttrs.postPatch or "" + ''
      cat >>deps.hex <<EOF

      absinthe_phoenix = ">= 0.0.0"
      EOF
    '';
  });
}
