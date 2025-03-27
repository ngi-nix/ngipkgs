{
  replaceVars,
  musl-cross-make-sources,
  ...
}:

[
  {
    name = "0001-musl-cross-make-Use-pre-downloaded-sources.patch";
    patch = replaceVars ./0001-musl-cross-make-Use-pre-downloaded-sources.patch.in {
      inherit musl-cross-make-sources;
    };
  }
]
