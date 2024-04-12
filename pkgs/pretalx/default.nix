{
  pretalx,
  withPlugins ? [],
}:
pretalx.overrideAttrs (
  finalAttrs: previousAttrs: {
    propagatedBuildInputs = previousAttrs.propagatedBuildInputs ++ withPlugins;
    postInstall =
      previousAttrs.postInstall
      + ''
        cp $out/bin/${previousAttrs.meta.mainProgram} $out/bin/${finalAttrs.meta.mainProgram}
      '';
    passthru =
      previousAttrs.passthru
      // {
        PYTHONPATH = "${pretalx.python.pkgs.makePythonPath finalAttrs.propagatedBuildInputs}:${pretalx.outPath}/${pretalx.python.sitePackages}";
      };
    meta =
      previousAttrs.meta
      // {
        mainProgram = "pretalx";
      };
  }
)
