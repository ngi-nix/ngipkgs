{
  coreutils,
  jq,
  lib,
  nix,
  opam-nix,
  stdenv,
  writeShellApplication,
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
      opamPackages ? opam-nix.queryToScope { } ({ mirage = "*"; } // query),
      ...
    }:
    target:
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
        runHook preInstall
        cp -R . $out
        runHook postInstall
      '';
    };

  # Description: read opam files from mirage configuration
  # and build a unikernel in a separate output
  # for each one of the given targets.
  build = lib.extendMkDerivation {
    constructDrv = stdenv.mkDerivation;
    excludeDrvArgNames = [
      "materializedDir"
      "monorepoQuery"
      "overrideUnikernel"
      "query"
      "queryArgs"
    ];
    extendDrvArgs =
      finalAttrs:
      {
        pname,
        version,
        targets,
        src,
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
        mirageConfIFD = configure args;
        mirageConf =
          target:
          configure (
            args
            // {
              opamPackages = packages target;
            }
          ) target;
        packagesMaterialized =
          target: opam-nix.materializeOpamProject { } "${name}-${target}" (mirageConfIFD target) query;
        monorepoMaterialized =
          target: opam-nix.materializeBuildOpamMonorepo { } (mirageConfIFD target) monorepoQuery;
        monorepo =
          target: opam-nix.unmaterializeQueryToMonorepo { } (materializedDir + "/${target}/monorepo.json");
        packages =
          target:
          (opam-nix.materializedDefsToScope {
            sourceMap."${name}-${target}" = finalAttrs.passthru.mirageConf.${target};
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
                        lib.mapAttrsToList (name: path: "cp -r ${path} duniverse/${lib.toLower name}") (
                          finalAttrs.passthru.monorepo.${target}
                        )
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
        inherit src;
        outputs = [ "out" ] ++ targets;
        installPhase = ''
          runHook preInstall
          ${
            if stdenv.hostPlatform.isLinux && lib.elem "unix" targets then
              "ln -s $unix $out"
            else if stdenv.hostPlatform.isDarwin && lib.elem "macosx" targets then
              "ln -s $macosx $out"
            else
              "mkdir $out"
          }
          ${lib.concatMapStringsSep "\n" (target: ''
            cp -R ${finalAttrs.passthru.packages.${target}."${name}-${target}"} ''$${target}
          '') targets}
          runHook postInstall
        '';
        passthru = {
          updateScript = writeShellApplication {
            name = "dnsvizor-update";
            runtimeInputs = [
              coreutils
              jq
              nix
            ];
            text = ''
              set -x
              materializedDir=$(nix --extra-experimental-features nix-command -L eval \
                -f. ${pname}.passthru.materializedDir)
            ''
            + lib.concatMapStringsSep "\n" (target: ''
              mkdir -p "${materializedDir}/${target}/"
              packagesJson=$(nix --extra-experimental-features nix-command -L build \
                --no-link --print-out-paths --allow-import-from-derivation --show-trace \
                -f. ${pname}.passthru.packagesMaterialized.${target})
              jq <"$packagesJson" >"''${materializedDir}/${target}/packages.json"
              monorepoJson=$(nix --extra-experimental-features nix-command -L build \
                --no-link --print-out-paths --allow-import-from-derivation --show-trace \
                -f. ${pname}.passthru.monorepoMaterialized.${target})
              jq <"$monorepoJson" >"''${materializedDir}/${target}/monorepo.json"
            '') targets;
          };
          mirageConfIFD = lib.genAttrs targets mirageConfIFD;
          mirageConf = lib.genAttrs targets mirageConf;
          monorepoMaterialized = lib.genAttrs targets monorepoMaterialized;
          packagesMaterialized = lib.genAttrs targets packagesMaterialized;
          packages = lib.genAttrs targets packages;
          monorepo = lib.genAttrs targets monorepo;
          inherit materializedDir;
        };
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
