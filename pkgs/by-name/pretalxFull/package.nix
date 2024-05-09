{
  pretalx,
  pretalx-downstream,
  pretalx-media-ccc-de,
  pretalx-pages,
  pretalx-public-voting,
  pretalx-venueless,
  pretalx-vimeo,
  pretalx-youtube,
  withPlugins ? [
    pretalx-downstream
    pretalx-media-ccc-de
    pretalx-pages
    pretalx-public-voting
    pretalx-venueless
    pretalx-vimeo
    pretalx-youtube
  ],
}:
pretalx.overrideAttrs (
  finalAttrs: previousAttrs: {
    propagatedBuildInputs = previousAttrs.propagatedBuildInputs ++ withPlugins;
    pythonRelaxDeps = true;
    passthru =
      previousAttrs.passthru
      // {
        PYTHONPATH = "${pretalx.python.pkgs.makePythonPath finalAttrs.propagatedBuildInputs}:${finalAttrs.finalPackage.outPath}/${pretalx.python.sitePackages}";
      };
  }
)
