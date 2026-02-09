{
  coreutils,
  jq,
  lib,
  nix,
  opam-nix,
  stdenv,
  writeShellApplication,
  removeReferencesTo,
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
    }:
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

                nativeBuildInputs = previousAttrs.nativeBuildInputs or [ ] ++ [
                  removeReferencesTo
                ];

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
                # By not propagating inputs, stripping and removing
                # huge Solo5 and OCaml compilers inherited from packages-materialized.
                doNixSupport = false;
                stripAllList = previousAttrs.stripAllList or [ ] ++ [ "." ];
                preFixup = previousAttrs.preFixup or "" + "\n" + ''
                  remove-references-to ${
                    lib.escapeShellArgs (
                      lib.concatMap
                        (drv: [
                          "-t"
                          drv
                        ])
                        (
                          lib.optionals (finalOpam ? "ocaml-solo5") [
                            finalOpam.ocaml-solo5
                            finalOpam.solo5
                          ]
                        )
                    )
                  } $out/*
                '';
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
      targets,
      packages-materialized-path,
      monorepo-materialized-path,
      overrideAttrs ? _finalAttrs: _previousAttrs: { },
      ...
    }@args:
    let
      self = lib.genAttrs targets (
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
                updateScript = writeShellApplication {
                  name = "${pname}-${target}-update";
                  runtimeInputs = [
                    coreutils
                    jq
                    nix
                  ];
                  text = ''
                    set -x
                    packagesJson=$(nix --extra-experimental-features nix-command -L build \
                      --no-link --print-out-paths --allow-import-from-derivation -f. \
                      ${pname}.${target}.packages-materialized)
                    jq <"$packagesJson" |
                    install -Dm660 /dev/stdin pkgs/by-name/${pname}/packages-materialized/${target}.json

                    monorepoJson=$(nix --extra-experimental-features nix-command -L build \
                      --no-link --print-out-paths --allow-import-from-derivation -f. \
                      ${pname}.${target}.monorepo-materialized)
                    jq <"$monorepoJson" |
                    install -Dm660 /dev/stdin pkgs/by-name/${pname}/monorepo-materialized/${target}.json
                  '';
                };
              };
            }) overrideAttrs
          )
      );
    in
    lib.recurseIntoAttrs (
      self
      // {
        updateScript = writeShellApplication {
          name = "dnsvizor-update";
          runtimeInputs = [
            jq
            nix
          ];
          text = lib.concatMapStringsSep "\n" (target: lib.getExe self.${target}.updateScript) targets;
        };
      }
    );
}
