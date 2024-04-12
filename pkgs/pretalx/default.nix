{
  pretalx,
  withPlugins ? [],
}:
pretalx.overrideAttrs (
  finalAttrs: previousAttrs: {
    propagatedBuildInputs = previousAttrs.propagatedBuildInputs ++ withPlugins;
    passthru =
      previousAttrs.passthru
      // {
        PYTHONPATH = "${pretalx.python.pkgs.makePythonPath finalAttrs.propagatedBuildInputs}:${pretalx.outPath}/${pretalx.python.sitePackages}";
      };
  }
)
