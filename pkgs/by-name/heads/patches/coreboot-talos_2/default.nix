{
  replaceVars,
  bashInterpreter,
  buildConfig,
  hostConfig,
  ...
}:

[
  {
    name = "0001-coreboot-Make-build-verbose.patch";
    patch = ./0001-coreboot-Make-build-verbose.patch;
  }
  # TODO
  # This patch conflicts with a patch that Heads wants to apply. Haven't checked if their patch might already address
  # what this one is doing, because the board target currently doesn't build.
  /*
    {
      name = "0002-coreboot-Hardcode-build-and-host-configure-flags.patch";
      patch = replaceVars ./0002-coreboot-Hardcode-build-and-host-configure-flags.patch.in {
        inherit buildConfig hostConfig;
      };
    }
  */
]
