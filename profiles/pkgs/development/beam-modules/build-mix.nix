{
  elixir,
  erlang,
  hex,
  beamModuleInstallHook,
  mixBuildDirHook,
  mixCompileHook,
  makeSetupHook,

  lib,
  stdenv,
  writeText,
}:

let
  beamCopySourceHook = makeSetupHook {
    name = "beam-copy-source-hook.sh";
    meta.license = lib.licenses.mit;
  } build-mix/beam-copy-source-hook.sh;

  beamCopySourceNonDeterministicHook = makeSetupHook {
    name = "beam-copy-source-non-deterministic-hook.sh";
    meta.license = lib.licenses.mit;
  } build-mix/beam-copy-source-non-deterministic-hook.sh;

  mixAppConfigPatchHook = makeSetupHook {
    name = "mix-config-patch-hook.sh";
    meta.license = lib.licenses.mit;
  } build-mix/mix-app-config-patch-hook.sh;
in

lib.extendMkDerivation {
  constructDrv = stdenv.mkDerivation;
  excludeDrvArgNames = [
    "mixEnv"
  ];
  extendDrvArgs =
    finalAttrs:
    {
      beamDeps ? finalAttrs.beamDeps or [ ],
      mixEnv ? finalAttrs.mixEnv or "prod",
      mixTarget ? finalAttrs.mixTarget or "host",

      # Allow passing compile time config instead of an empty config
      appConfigPath ? finalAttrs.appConfigPath or null,

      enableDebugInfo ? finalAttrs.enableDebugInfo or false,
      erlangCompilerOptions ? finalAttrs.erlangCompilerOptions or [ ],
      # Deterministic Erlang builds remove full system paths from debug information
      # among other things to keep builds more reproducible. See their docs for more:
      # https://www.erlang.org/doc/man/compile
      #
      # Explanation: default to false because it breaks apps using Surface
      # and does not improve determinism within a sandboxed nix build
      # which always builds in the same path anyway.
      erlangDeterministicBuilds ? finalAttrs.erlangDeterministicBuilds or true,
      ...
    }@previousAttrs:
    {
      name = "erlang${erlang.version}-${previousAttrs.name}-${finalAttrs.version}";

      env = {
        ERL_COMPILER_OPTIONS =
          let
            options = erlangCompilerOptions ++ lib.optionals erlangDeterministicBuilds [ "deterministic" ];
          in
          "[${lib.concatStringsSep "," options}]";

        MIX_ENV = mixEnv;
        MIX_TARGET = mixTarget;
        MIX_BUILD_PREFIX = (if mixTarget == "host" then "" else "${mixTarget}_") + "${mixEnv}";
        MIX_DEBUG = if enableDebugInfo then 1 else 0;
        HEX_OFFLINE = 1;

        LANG = if stdenv.hostPlatform.isLinux then "C.UTF-8" else "C";
        LC_CTYPE = if stdenv.hostPlatform.isLinux then "C.UTF-8" else "UTF-8";

        # some hooks need name-version, but we've overridden name above for the nix package
        beamModuleName = previousAttrs.name;
      }
      // previousAttrs.env or { };

      __darwinAllowLocalNetworking = true;

      # add to ERL_LIBS so other modules can find at runtime.
      # http://erlang.org/doc/man/code.html#code-path
      # Mix also searches the code path when compiling with the --no-deps-check flag
      # This is used by package builders such as mixRelease
      setupHook = writeText "setupHook.sh" ''
        addToSearchPath ERL_LIBS "$1/lib/erlang/lib"
      '';

      nativeBuildInputs = (previousAttrs.nativeBuildInputs or [ ]) ++ [
        elixir
        hex

        (if erlangDeterministicBuilds then beamCopySourceHook else beamCopySourceNonDeterministicHook)
        beamModuleInstallHook
        mixBuildDirHook
        mixCompileHook
        mixAppConfigPatchHook
      ];

      propagatedBuildInputs = (previousAttrs.propagatedBuildInputs or [ ]) ++ beamDeps;

      passthru = (previousAttrs.passthru or { }) // {
        inherit beamDeps;
      };
    };
}
