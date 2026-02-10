{
  coreutils,
  jq,
  lib,
  nix,
  opam-nix,
  stdenv,
  writeShellApplication,
}:

let
  excludeDrvArgNames = [
    "target"
    "targets"
    "materializedDir"
    "monorepoQuery"
    "overrideUnikernel"
    "query"
    "queryArgs"
    "opamPackages"
    "mirageDir"
  ];
in

rec {
  # Description: run `mirage configure` on source,
  # with mirage, dune, and ocaml from `opam-nix`.
  configure = lib.extendMkDerivation {
    constructDrv = stdenv.mkDerivation;
    inherit excludeDrvArgNames;
    extendDrvArgs =
      finalAttrs:
      {
        pname,
        target,
        opamPackages,
        mirageDir ? finalAttrs.mirageDir or ".",
        ...
      }:
      {
        name = "mirage-${pname}-${target}";
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
          runHook preInstall
          cp -R . $out
          runHook postInstall
        '';
      };
  };

  # Description: read opam files from mirage configuration
  # and build a unikernel for the given target.
  build = lib.extendMkDerivation {
    constructDrv = stdenv.mkDerivation;
    inherit excludeDrvArgNames;
    extendDrvArgs =
      finalAttrs:
      {
        pname,
        version,
        src,
        target,
        monorepoQuery,
        materializedDir,
        mirageDir ? ".",
        queryArgs ? { },
        query ? { },
        overrideUnikernel ? finalAttrs: previousAttrs: { },
        ...
      }@args:
      let
        name = "mirage-${pname}";
        mirageConfIFD = configure (
          args
          // {
            inherit target;
            opamPackages = opam-nix.queryToScope { } ({ mirage = "*"; } // query);
          }
        );
        mirageConf = configure (
          args
          // {
            inherit target;
            opamPackages = packages;
          }
        );
        packagesMaterialized = opam-nix.materializeOpamProject { } "${name}-${target}" mirageConfIFD query;
        monorepoMaterialized = opam-nix.materializeBuildOpamMonorepo { } mirageConfIFD monorepoQuery;
        monorepo = opam-nix.unmaterializeQueryToMonorepo { } (materializedDir + "/${target}/monorepo.json");
        packages =
          (opam-nix.materializedDefsToScope {
            sourceMap."${name}-${target}" = finalAttrs.passthru.mirageConf;
          } (materializedDir + "/${target}/packages.json")).overrideScope
            (
              finalOpam: previousOpam: {
                "${name}-${target}" = previousOpam."${name}-${target}".overrideAttrs (
                  lib.composeExtensions (finalUnikernel: previousUnikernel: {
                    inherit version;
                    __intentionallyOverridingVersion = true;

                    env =
                      previousUnikernel.env or { }
                      // lib.optionalAttrs (finalOpam ? "ocaml-solo5") {
                        OCAMLFIND_CONF = finalOpam.ocaml-solo5 + "/lib/findlib.conf";
                      };

                    buildPhase = ''
                      runHook preBuild
                      mkdir duniverse
                      echo '(vendored_dirs *)' > duniverse/dune
                      ${lib.concatStringsSep "\n" (
                        lib.mapAttrsToList (name: path: ''
                          cp -r ${path} duniverse/${lib.toLower name}
                        '') finalAttrs.passthru.monorepo
                      )}
                      dune build ${mirageDir} --profile release
                      runHook postBuild
                    '';

                    installPhase = ''
                      runHook preInstall
                      mkdir -p $out/share/mirageos/
                      cp -L ${mirageDir}/dist/${pname}* $out/share/mirageos/
                      runHook postInstall
                    '';

                    # Reduce the full closure size by several hundreds MiB
                    # since if you're using an unikernel you probably care about this.
                    doNixSupport = false;
                    stripAllList = previousUnikernel.stripAllList or [ ] ++ [ "share/mirageos" ];
                  }) overrideUnikernel
                );
              }
            );
      in
      {
        inherit name;
        installPhase = ''
          runHook preInstall
          cp -R --no-preserve=mode ${finalAttrs.passthru.packages."${name}-${target}"} $out
          ${lib.optionalString
            (
              (stdenv.hostPlatform.isLinux && target == "unix")
              || (stdenv.hostPlatform.isDarwin && target == "macosx")
            )
            ''
              install -Dm755 $out/share/mirageos/${pname} $out/bin/${pname}
              rm -rf $out/share
            ''
          }
          runHook postInstall
        '';
        passthru = {
          updateScript = lib.getExe (writeShellApplication {
            name = "${pname}-update-${target}";
            runtimeInputs = [
              coreutils
              jq
              nix
            ];
            text = ''
              set -x
              materializedDir=$(nix --extra-experimental-features nix-command -L eval \
                -f. ${pname}.passthru.${target}.passthru.materializedDir)
              mkdir -p "$materializedDir/${target}/"
              packagesJson=$(nix --extra-experimental-features nix-command -L build \
                --no-link --print-out-paths --allow-import-from-derivation --show-trace \
                -f. ${pname}.passthru.${target}.passthru.packagesMaterialized)
              jq <"$packagesJson" >"$materializedDir/${target}/packages.json"
              monorepoJson=$(nix --extra-experimental-features nix-command -L build \
                --no-link --print-out-paths --allow-import-from-derivation --show-trace \
                -f. ${pname}.passthru.${target}.passthru.monorepoMaterialized)
              jq <"$monorepoJson" >"$materializedDir/${target}/monorepo.json"
            '';
          });
          inherit
            materializedDir
            mirageConf
            mirageConfIFD
            monorepo
            monorepoMaterialized
            packages
            packagesMaterialized
            ;
        };
      };
  };

  # Description: build all given targets
  # or only a single if accessed in `passthru.${target}`.
  builds = lib.extendMkDerivation {
    constructDrv = stdenv.mkDerivation;
    inherit excludeDrvArgNames;
    extendDrvArgs =
      finalAttrs:
      {
        pname,
        targets ? finalAttrs.targets or possibleTargets,
        ...
      }@args:
      {
        passthru = lib.genAttrs targets (target: build (args // { inherit target; })) // {
          updateScript = lib.getExe (writeShellApplication {
            name = "${pname}-update";
            text = lib.concatMapStringsSep "\n" (target: ''
              ${finalAttrs.passthru.${target}.passthru.updateScript}
            '') targets;
          });
        };
        phases = [ "installPhase" ];
        installPhase = ''
          runHook preInstall
          mkdir -p $out
          runHook postInstall
        '';
      };
  };

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
}
