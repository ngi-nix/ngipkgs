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
  {
    name = "0002-coreboot-Hardcode-build-and-host-configure-flags.patch";
    patch = replaceVars ./0002-coreboot-Hardcode-build-and-host-configure-flags.patch.in {
      inherit buildConfig hostConfig;
    };
  }
]
