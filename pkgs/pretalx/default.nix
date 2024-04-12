{
  pretalx,
  withPlugins ? [],
  nixosTests,
}:
pretalx.overrideAttrs (
  finalAttrs: previousAttrs: {
    name = "pretalx-test";
    propagatedBuildInputs = previousAttrs.propagatedBuildInputs ++ withPlugins;
    passthru =
      previousAttrs.passthru
      // {
        PYTHONPATH = "${pretalx.python.pkgs.makePythonPath finalAttrs.propagatedBuildInputs}:${pretalx.outPath}/${pretalx.python.sitePackages}";
        tests =
          previousAttrs.passthru.tests
          // {
            inherit (nixosTests) pretalx;
          };
      };
  }
)
