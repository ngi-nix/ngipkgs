{
  stdenv,
  writeText,
  elixir,
  hex,
  lib,
  pkgs,
}:

let
  shell =
    drv:
    stdenv.mkDerivation {
      name = "interactive-shell-${drv.name}";
      buildInputs = [ drv ];
    };
in

lib.extendMkDerivation {
  constructDrv = stdenv.mkDerivation;
  excludeDrvArgNames = [
  ];
  extendDrvArgs =
    finalAttrs:
    {
      name,
      version,
      src,
      buildInputs ? [ ],
      nativeBuildInputs ? [ ],
      propagatedBuildInputs ? [ ],
      postPatch ? "",
      meta ? { },
      erlangCompilerOptions ? finalAttrs.erlangCompilerOptions or [ ],
      # Deterministic Erlang builds remove full system paths from debug information
      # among other things to keep builds more reproducible. See their docs for more:
      # https://www.erlang.org/doc/man/compile
      # Default to false because it breaks apps using Surface
      # and does not improve determinisme within a sandboxed nix build
      # which always builds in the same path.
      erlangDeterministicBuilds ? finalAttrs.erlangDeterministicBuilds or false,
      beamDeps ? finalAttrs.beamDeps or [ ],
      compilePorts ? finalAttrs.compilePorts or false,
      enableDebugInfo ? finalAttrs.enableDebugInfo or false,
      mixEnv ? finalAttrs.mixEnv or "prod",
      mixTarget ? finalAttrs.mixTarget or "host",
      removeConfig ? finalAttrs.removeConfig or true,
      # A config directory that is considered for all the dependencies of an app, typically in $src/config/
      # This was initially added, as some of Mobilizon's dependencies need to access the config at build time.
      appConfigPath ? finalAttrs.appConfigPath or null,
      env ? { },
      ...
    }@previousAttrs:
    #assert finalAttrs.appConfigPath != null -> finalAttrs.removeConfig;
    lib.recursiveUpdate previousAttrs {
      # ToDo(maint): is it useful?
      name = "${name}-${finalAttrs.version}";
      inherit version src;

      env = env // {
        ERL_COMPILER_OPTIONS =
          let
            options = erlangCompilerOptions ++ lib.optionals erlangDeterministicBuilds [ "deterministic" ];
          in
          "[${lib.concatStringsSep "," options}]";
        HEX_OFFLINE = 1;
        LANG = if stdenv.hostPlatform.isLinux then "C.UTF-8" else "C";
        LC_CTYPE = if stdenv.hostPlatform.isLinux then "C.UTF-8" else "UTF-8";
        MIX_BUILD_PREFIX = (if mixTarget == "host" then "" else "${mixTarget}_") + "${mixEnv}";
        MIX_DEBUG = if enableDebugInfo then 1 else 0;
        MIX_ENV = mixEnv;
        MIX_TARGET = mixTarget;
      };

      __darwinAllowLocalNetworking = true;

      # add to ERL_LIBS so other modules can find at runtime.
      # http://erlang.org/doc/man/code.html#code-path
      # Mix also searches the code path when compiling with the --no-deps-check flag
      setupHook = previousAttrs.setupHook or writeText "setupHook.sh" ''
        addToSearchPath ERL_LIBS "$1/lib/erlang/lib"
      '';

      postUnpack = ''
        mkdir -p $out
        cp -r $sourceRoot $out/src
        src=$out/src
        sourceRoot=$out/src
      '';

      nativeBuildInputs = nativeBuildInputs ++ [
        elixir
        hex
      ];
      propagatedBuildInputs = propagatedBuildInputs ++ beamDeps;

      configurePhase =
        previousAttrs.configurePhase or ''
          runHook preConfigure

          ${pkgs.path + "/pkgs/development/beam-modules/mix-configure-hook.sh"}
          ${lib.optionalString (removeConfig && isNull appConfigPath)
            # By default, we don't want to include whatever config a dependency brings; per
            # https://hexdocs.pm/elixir/main/Config.html, config is application specific.
            ''
              rm -rf config
              mkdir config
            ''
          }
          ${lib.optionalString (!isNull appConfigPath)
            # Some more tightly-coupled dependencies do depend on the config of the application
            # they're being built for.
            ''
              rm -rf config
              cp -r ${appConfigPath} config
            ''
          }

          runHook postConfigure
        '';

      buildPhase =
        previousAttrs.buildPhase or ''
          runHook preBuild
          export HEX_HOME="$TEMPDIR/hex"
          export MIX_HOME="$TEMPDIR/mix"
          mix compile --no-deps-check
          runHook postBuild
        '';

      installPhase =
        previousAttrs.installPhase or ''
          runHook preInstall

          # This uses the install path convention established by nixpkgs maintainers
          # for all beam packages. Changing this will break compatibility with other
          # builder functions like buildRebar3 and buildErlangMk.
          mkdir -p "$out/lib/erlang/lib/${name}-${version}"

          # Some packages like db_connection will use _build/shared instead of
          # honoring the $MIX_ENV variable.
          for reldir in _build/{$MIX_BUILD_PREFIX,shared}/lib/${name}/{src,ebin,priv,include} ; do
            if test -d $reldir ; then
              # Some builds produce symlinks (eg: phoenix priv dircetory). They must
              # be followed with -H flag.
              cp  -Hrt "$out/lib/erlang/lib/${name}-${version}" "$reldir"
            fi
          done

          # Copy the source so it can be used by dependent packages. For example,
          # phoenix applications need the source of phoenix and phoenix_html to
          # build javascript and css assets.
          rm -rf _build

          runHook postInstall
        '';

      # stripping does not have any effect on beam files
      # it is however needed for dependencies with NIFs like bcrypt for example
      dontStrip = false;

      passthru = {
        packageName = name;
        #env = shell self;
        inherit beamDeps;
      };
    };
}
