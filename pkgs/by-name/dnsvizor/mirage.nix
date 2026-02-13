{
  coreutils,
  jq,
  lib,
  nix,
  opam-nix,
  stdenv,
  writeShellApplication,
  unstableGitUpdater,
  git,
  emptyDirectory,
}:

rec {
  # Description: run `mirage configure` on source,
  # with mirage, dune, and ocaml from `opam-nix`.
  configure =
    {
      pname,
      version,
      mirageDir ? ".",
      query,
      src,
      target,
      opamPackages ? opam-nix.queryToScope { } ({ mirage = "*"; } // query),
      ...
    }@args:
    stdenv.mkDerivation {
      name = "mirage-${pname}-${target}";
      inherit src version;
      buildInputs = with opamPackages; [ mirage ];
      nativeBuildInputs = with opamPackages; [
        dune
        ocaml
      ];
      buildPhase = ''
        runHook preBuild
        mirage configure -f ${mirageDir}/config.ml -t ${target}
        # Move Opam file to root so a recursive search for opam files isn't required.
        # Prefix it so it doesn't interfere with other packages.
        cp ${mirageDir}/mirage/${pname}-${target}.opam mirage-${pname}-${target}.opam
        runHook postBuild
      '';
      installPhase = ''
        runHook preBuild
        cp -R . $out
        runHook postBuild
      '';
      pos = builtins.unsafeGetAttrPos "src" args;
    };

  # Description: read opam files from mirage-conf and build the unikernel.
  build =
    {
      pname,
      version,
      mirageDir ? ".",
      queryArgs ? { },
      query ? { },
      monorepoQuery,
      packages-materialized-path,
      monorepo-materialized-path,
      target,
      overrideAttrs ? finalAttrs: previousAttrs: { },
      ...
    }@args:
    let
      name = "mirage-${pname}-${target}";
      mirage-conf = configure args;
      mirage-conf-unmaterialized = configure (
        args
        // {
          opamPackages = packages-unmaterialized;
        }
      );
      packages-materialized = opam-nix.materializeOpamProject { } name mirage-conf query;
      monorepo-materialized = opam-nix.materializeBuildOpamMonorepo { } mirage-conf monorepoQuery;
      monorepo-unmaterialized = opam-nix.unmaterializeQueryToMonorepo { } monorepo-materialized-path;
      packages-unmaterialized =
        (opam-nix.materializedDefsToScope {
          sourceMap.${name} = mirage-conf-unmaterialized;
        } packages-materialized-path).overrideScope
          (
            finalOpam: previousOpam: {
              ${name} = previousOpam.${name}.overrideAttrs (previousAttrs: {
                inherit version;
                __intentionallyOverridingVersion = true;

                env =
                  previousAttrs.env or { }
                  // lib.optionalAttrs (finalOpam ? "ocaml-solo5") {
                    OCAMLFIND_CONF = finalOpam.ocaml-solo5 + "/lib/findlib.conf";
                  };

                buildPhase = ''
                  runHook preBuild
                  mkdir duniverse
                  echo '(vendored_dirs *)' > duniverse/dune
                  ${lib.concatStringsSep "\n" (
                    lib.mapAttrsToList (
                      # ToDo: get dune build to pick up symlinks?
                      name: path: "cp -r ${path} duniverse/${lib.toLower name}"
                    ) monorepo-unmaterialized
                  )}
                  # Note: doesn't fail on warnings
                  dune build ${mirageDir} --profile release
                  runHook postBuild
                '';

                installPhase = ''
                  runHook preInstall
                  mkdir $out
                  cp -L ${mirageDir}/dist/${pname}* $out/
                  runHook postInstall
                '';

                # Reduce the full closure size by several hundreds MiB
                # By not propagating inputs and stripping all symbols.
                doNixSupport = false;
                stripAllList = previousAttrs.stripAllList or [ ] ++ [ "." ];
              });
            }
          );
      unikernel =
        if lib.pathExists packages-materialized-path && lib.pathExists monorepo-materialized-path then
          packages-unmaterialized.${name}
        else
          # Give access to `passthru` when materialized files
          # have not yet been generated.
          stdenv.mkDerivation {
            name = "stub";
            src = null;
          };
    in
    unikernel.overrideAttrs (previousAttrs: {
      passthru = previousAttrs.passthru or { } // {
        inherit
          mirage-conf
          mirage-conf-unmaterialized
          monorepo-materialized
          packages-materialized
          packages-unmaterialized
          ;
      };
    });

  possibleTargets = [
    "genode"
    "hvt"
    "macosx"
    "muen"
    "qubes"
    "spt"
    "unix"
    "virtio"
    "xen"
  ];

  builds =
    {
      pname,
      src,
      targets,
      packages-materialized-path,
      monorepo-materialized-path,
      overrideAttrs ? _finalAttrs: _previousAttrs: { },
      ...
    }@args:
    let
      # deps of all targets, together with src and related flake inputs, are updated in lockstep
      depsUpdateScript = lib.getExe (writeShellApplication {
        name = "${pname}-update";
        inherit runtimeInputs;
        text =
          let
            updateSrc = lib.escapeShellArgs (unstableGitUpdater {
              url = src.gitRepoUrl;
            });
          in
          ''
            set -x

            srcUpdateJson=$(UPDATE_NIX_ATTR_PATH=${pname}.${lib.head targets}.mirage-conf \
              ${updateSrc} | \
              jq '.[] += {attrPath:"${pname}"} | .[]')

            # update opam-related flake inputs because they are used when updating deps
            nix --extra-experimental-features "nix-command flakes" \
              flake update opam-repository opam-overlays mirage-opam-overlays

            declare -a updatedFiles
            # work around "unbound variable" error of empty array caused by set -u
            updatedFiles+=()

            ${lib.concatLines (map updateDepsForTarget targets)}

            flakeLockFile="flake.lock"
            depsUpdateJson=""
            if [ ''${#updatedFiles[@]} -gt 0 ]; then
              if [ "$(git diff --name-only "$flakeLockFile")" != "" ]; then
                updatedFiles+=("$flakeLockFile")
              fi
              depsUpdateJson=$(jq --null-input \
                '{"attrPath":"${pname}","oldVersion":"0","newVersion":"0","commitMessage":"${pname}: update deps","files":$ARGS.positional}' \
                --args -- "''${updatedFiles[@]}")
            fi

            jq --slurp <<< "$srcUpdateJson$depsUpdateJson"
          '';
      });
      depsUpdateScriptForTarget =
        target:
        writeShellApplication {
          name = "${pname}-${target}-deps-update";
          inherit runtimeInputs;
          text = ''
            set -x
            ${updateDepsForTarget target}
          '';
        };
      runtimeInputs = [
        nix
        jq
        coreutils
        git
      ];
      updateDepsForTarget = target: ''
        packagesMaterializedFile="pkgs/by-name/${pname}/packages-materialized/${target}.json"
        packagesJson=$(nix --extra-experimental-features nix-command -L build \
          --no-link --print-out-paths --allow-import-from-derivation -f. \
          ${pname}.${target}.packages-materialized)
        jq <"$packagesJson" |
        install -Dm660 /dev/stdin "$packagesMaterializedFile"
        if [ "$(git diff --name-only "$packagesMaterializedFile")" != "" ]; then
          updatedFiles+=("$packagesMaterializedFile")
        fi

        monorepoMaterializedFile="pkgs/by-name/${pname}/monorepo-materialized/${target}.json"
        monorepoJson=$(nix --extra-experimental-features nix-command -L build \
          --no-link --print-out-paths --allow-import-from-derivation -f. \
          ${pname}.${target}.monorepo-materialized)
        jq <"$monorepoJson" |
        install -Dm660 /dev/stdin "$monorepoMaterializedFile"
        if [ "$(git diff --name-only "$monorepoMaterializedFile")" != "" ]; then
          updatedFiles+=("$monorepoMaterializedFile")
        fi
      '';
    in
    lib.genAttrs targets (
      target:
      (build (
        args
        // {
          inherit target;
          monorepo-materialized-path = monorepo-materialized-path + "/${target}.json";
          packages-materialized-path = packages-materialized-path + "/${target}.json";
        }
      )).overrideAttrs
        (
          lib.composeExtensions (finalAttrs: previousAttrs: {
            passthru = previousAttrs.passthru or { } // {
              depsUpdateScriptForThisTarget = depsUpdateScriptForTarget target;
            };
          }) overrideAttrs
        )
    )
    // {
      update = stdenv.mkDerivation {
        pname = "${pname}-update";
        version = "0";
        src = emptyDirectory;
        installPhase = ''
          runHook preInstall
          echo "This dummy package contains an updateScript updating the package set." > $out
          runHook postInstall
        '';
        passthru.updateScript = {
          command = depsUpdateScript;
          supportedFeatures = [ "commit" ];
        };
      };
    };
}
