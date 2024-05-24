{pretalx}: let
  pretalxFull = pretalx.override {
    plugins = with pretalx.plugins; [
      downstream
      media-ccc-de
      pages
      public-voting
      venueless
      vimeo
      youtube
    ];
  };
in
  pretalxFull.overrideAttrs (
    finalAttrs: previousAttrs: {
      passthru =
        previousAttrs.passthru
        // {
          PYTHONPATH = "${pretalxFull.python.pkgs.makePythonPath finalAttrs.propagatedBuildInputs}:${finalAttrs.finalPackage.outPath}/${pretalxFull.python.sitePackages}";
        };
    }
  )
