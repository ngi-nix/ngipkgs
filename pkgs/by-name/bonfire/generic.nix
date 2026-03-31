{
  stdenv,
  beam,
  bonfire,
  cacert,
  callPackage,
  callPackages,
  cmake,
  fetchFromGitHub,
  fetchYarnDeps,
  just,
  lexbor,
  lib,
  nix,
  nodejs,
  nurl,
  cargo,
  oniguruma,
  pkg-config,
  runCommandLocal,
  rustPlatform,
  writeShellApplication,
  yarn,
  yarn-berry_4,
  yarnConfigHook,
  ...
}:
let
  # ToDo(maintenance): use erlang_28 or erlang_29 after
  # https://github.com/bonfire-networks/bonfire-app/issues/2110
  beamPkgs = beam.packages.erlang_27.extend (
    final: previous: {
      buildMix = final.callPackage ../../../profiles/pkgs/development/beam-modules/build-mix.nix { };
      mixRelease = final.callPackage ../../../profiles/pkgs/development/beam-modules/mix-release.nix { };
    }
  );
in
beamPkgs.mixRelease (finalAttrs: {
  pname = "bonfire-${finalAttrs.env.FLAVOUR}";
  inherit (finalAttrs.passthru.beamPackages) erlang elixir;
  env = {
    FLAVOUR = "ember";

    WITH_AI = "1";
    WITH_IMAGE_VIX = "1";
    WITH_GIT_DEPS = "1";
    WITH_FORKS = "0";
    WITH_DOCKER = "no";
    COMPILE_ALL_LOCALES = "no";

    # Explanation: from justfile's _ext-migrations-copy
    MIX_OS_DEPS_COMPILE_PARTITION_COUNT = "1";

    # Remark: somehow lib/api/graphql_masto_adapter.ex
    # has become extremely slow to compile.
    # Issue: https://github.com/bonfire-networks/bonfire-app/issues/1730
    WITH_API_GRAPHQL = "1";

    # ToDo(functional/completeness): support this?
    #WITH_XMPP = "1";
  };
  passthru = {
    deps = ./extensions + "/${finalAttrs.env.FLAVOUR}/deps.nix";
    # Explanation: it's not possible to use deps_nix's Rust support in NGIpkgs
    # because its way to set `src` requires --allow-import-from-derivation
    overrideAttrsRust =
      {
        nativeDir,
        outputHashes ? { },
        sourceRoot ? null,
        regeneratedCargoLock ? false,
        buildFeatures ? [ ],
      }:
      finalRust: previousRust: {
        env = previousRust.env or { } // {
          # Explanation: config/bonfire_common.exs
          # uses this to set:
          # config :rustler_precompiled, force_build_all:
          # which is needed to let nix provision Rust libraries.
          RUSTLER_BUILD_ALL = "true";
        };
        preConfigure = ''
          mkdir -p priv/native
          for lib in ${finalRust.passthru.native}/lib/*
          do
            dest="$(basename "$lib")"
            if [[ "''${dest##*.}" = "dylib" ]]
            then
              dest="''${dest%.dylib}.so"
            fi
            ln -s "$lib" "priv/native/$dest"
          done
        '';
        passthru = previousRust.passthru // {
          inherit nativeDir;

          # Explanation: this is where `nativeDir` is found
          # but it cannot be used when import-from-derivation are disallowed.
          #nativeDir = with builtins; head (attrNames (readDir "${previousRust.src}/native"));
          native = rustPlatform.buildRustPackage (finalNative: {
            pname = "${previousRust.env.beamModuleName}-native";
            inherit (previousRust) version src;
            inherit buildFeatures;
            sourceRoot =
              if sourceRoot == null then
                "${previousRust.env.beamModuleName}-${previousRust.version}/native/${finalRust.passthru.nativeDir}"
              else
                sourceRoot;
            cargoLock = {
              lockFile =
                ./extensions + "/${finalAttrs.env.FLAVOUR}/${previousRust.env.beamModuleName}/Cargo.lock";
              inherit outputHashes;
            };
            passthru = {
              regeneratedCargoLock = stdenv.mkDerivation {
                pname = "${previousRust.env.beamModuleName}-native-regeneratedCargoLock";
                inherit (previousRust) version src;
                __noChroot = true;
                sourceRoot =
                  if sourceRoot == null then
                    "${previousRust.env.beamModuleName}-${previousRust.version}/native/${finalRust.passthru.nativeDir}"
                  else
                    sourceRoot;
                buildInputs = [
                  cacert
                  cargo
                ];
                # Upstream's `Cargo.lock` does not include hashsum for `lumis*` crates
                # but those are required by `importCargoLock`
                # to populate the offline cache for `cargo`.
                buildPhase = ''
                  cargo generate-lockfile
                '';
                installPhase = ''
                  cp Cargo.lock $out
                '';
              };
            };
            prePatch = lib.optionalString regeneratedCargoLock ''
              cp -fv ${
                #finalNative.cargoLock.lockFile
                ./extensions + "/${finalAttrs.env.FLAVOUR}/${previousRust.env.beamModuleName}/Cargo.lock"
              } Cargo.lock
            '';
            nativeBuildInputs = [
              cmake
            ];
            doCheck = false;
          });
          updateScript =
            let
              originalCargoLock = "${finalRust.src}/native/${finalRust.passthru.nativeDir}/Cargo.lock";
            in
            writeShellApplication {
              name = "${previousRust.env.beamModuleName}-update";
              text = ''
                set -eux
                install -Dm660 ${
                  if regeneratedCargoLock then
                    finalRust.passthru.native.passthru.regeneratedCargoLock
                  else
                    originalCargoLock
                } \
                  'pkgs/by-name/bonfire/extensions/${finalAttrs.env.FLAVOUR}/${previousRust.env.beamModuleName}/Cargo.lock'
              '';
            };
        };
      };

    # Explanation: `exla` depends on `xla`, which depends on openxla
    # `pkgs.xla` packages openxla but using a different configuration,
    xla = callPackage deps/xla/default.nix { xla = finalAttrs.passthru.mixNixDeps.xla; };

    mixNixDeps = callPackages finalAttrs.passthru.deps {
      inherit (finalAttrs.passthru) beamPackages;
      overrides =
        finalMixPkgs: previousMixPkgs:
        {
          decent = previousMixPkgs.decent.overrideAttrs (
            finalAttrs.passthru.overrideAttrsRust {
              nativeDir = "decent";
              sourceRoot = "source/native/decent";
            }
          );
          lumis = previousMixPkgs.lumis.overrideAttrs (
            finalAttrs.passthru.overrideAttrsRust {
              nativeDir = "lumis_nif";
              regeneratedCargoLock = true;
            }
          );
          mdex_native = previousMixPkgs.mdex_native.overrideAttrs (
            finalAttrs.passthru.overrideAttrsRust {
              nativeDir = "mdex_native_nif";
              # Explanation: MDEx's NIF only builds in the syntax highlighter when told to at compile time,
              # when using Elixir's `rustler` it's done with:
              # `config :mdex_native, syntax_highlighter: :lumis`
              # but here Nixpkgs' `buildRustPackage` is in charge.
              buildFeatures = [ "lumis" ];
            }
          );
          mjml = previousMixPkgs.mjml.overrideAttrs (
            finalAttrs.passthru.overrideAttrsRust {
              nativeDir = "mjml_nif";
            }
          );

          exla =
            (previousMixPkgs.exla.override (previousArgs: {
              beamDeps =
                previousArgs.beamDeps
                ++ (with finalMixPkgs; [
                  fine
                ]);
            })).overrideAttrs
              (previousMixPkg: {
                # Explanation: only required when deps.nix uses git, not the hex package.
                # sourceRoot = "source/exla";

                env = previousMixPkg.env or { } // {
                  FINE_INCLUDE_DIR = finalMixPkgs.fine + "/src/c_include";
                  EXLA_FORCE_REBUILD = "true";
                  XLA_ARCHIVE_PATH = finalAttrs.passthru.xla;
                  XLA_BUILD = "false";
                  #EXLA_CPU_ONLY = "true";
                  #XLA_TARGET = "cpu";
                  #XLA_TARGET_PLATFORM = …;
                };

                nativeBuildInputs = previousMixPkg.nativeBuildInputs or [ ] ++ [
                  #cmake
                ];

                postPatch = previousMixPkg.postPatch or "" + ''
                  substituteInPlace mix.exs \
                    --replace-fail "Fine.include_dir()" '"${finalMixPkgs.fine}/src/c_include"'
                '';

                preConfigure = previousMixPkg.preConfigure or "" + ''
                  export HOME="$PWD"
                  export ELIXIR_MAKE_CACHE_DIR="$TEMPDIR/elixir_make_cache"
                  export XLA_CACHE_DIR=cache
                  mkdir -p $out/cache
                  ln -s $out/cache cache
                  ln -s ${finalAttrs.passthru.xla} cache/xla_extension
                  printf %s >cache/xla_snapshot.txt ${finalAttrs.passthru.xla}
                '';
                preFixup = previousMixPkg.preFixup or "" + ''
                  rm -rf $out/cache/exla
                  find $out/cache -type f -not -name "*.so" -delete
                  find $out/cache -type d -empty -depth -delete
                '';
              });

          nx =
            (previousMixPkgs.nx.override (previousArgs: {
              beamDeps =
                previousArgs.beamDeps
                ++ (with finalMixPkgs; [
                  fine
                ]);
            })).overrideAttrs
              (previousMixPkg: {
                # Explanation: only required when deps.nix uses git, not the hex package.
                #sourceRoot = "source/nx";

                env = previousMixPkg.env or { } // {
                  FINE_INCLUDE_DIR = finalMixPkgs.fine + "/src/c_include";
                };

                nativeBuildInputs = previousMixPkg.nativeBuildInputs or [ ] ++ [
                  #cmake
                ];
              });
          tokenizers =
            (previousMixPkgs.tokenizers.overrideAttrs (
              finalAttrs.passthru.overrideAttrsRust {
                nativeDir = "ex_tokenizers";
              }
            )).overrideAttrs
              (previousAttrs: {
                passthru = previousAttrs.passthru or { } // {
                  # Issue: https://github.com/elixir-nx/tokenizers/pull/67
                  native = previousAttrs.passthru.native.overrideAttrs (previousRust: {
                    buildInputs = previousRust.buildInputs or [ ] ++ [ oniguruma ];
                    nativeBuildInputs = previousRust.nativeBuildInputs or [ ] ++ [ pkg-config ];
                    env = previousRust.env or { } // {
                      RUSTONIG_SYSTEM_LIBONIG = "1";
                    };
                  });
                };
              });
          bonfire_common = previousMixPkgs.bonfire_common.overrideAttrs (previousMixPkg: {
            # Explanation: remove a dangling symlink pointing out of bonfire_common…
            postPatch = previousMixPkg.postPatch or "" + ''
              rm priv/localisation
            '';
          });
          bonfire_data_access_control =
            (previousMixPkgs.bonfire_data_access_control.override (previousArgs: {
              beamDeps =
                previousArgs.beamDeps
                ++ (with finalMixPkgs; [
                  # Explanation: missing dependency in upstream deps.hex…
                  typed_ecto_schema
                ]);
            })).overrideAttrs
              (previousMixPkg: {
                postPatch = previousMixPkg.postPatch or "" + ''
                  cat >>deps.hex <<EOF

                  typed_ecto_schema = ">= 0.0.0"
                  EOF
                '';
              });
          bonfire_data_activity_pub =
            previousMixPkgs.bonfire_data_activity_pub.overrideAttrs
              (previousMixPkg: {
                # Explanation: missing transitive dependency in upstream's deps.hex…
                postPatch = previousMixPkg.postPatch or "" + ''
                  cat >>deps.hex <<EOF

                  typed_ecto_schema = ">= 0.0.0"
                  EOF
                '';
              });
          bonfire_data_edges = previousMixPkgs.bonfire_data_edges.overrideAttrs (previousMixPkg: {
            # Explanation: missing transitive dependency in upstream's deps.hex…
            postPatch = previousMixPkg.postPatch or "" + ''
              cat >>deps.hex <<EOF

              typed_ecto_schema = ">= 0.0.0"
              EOF
            '';
          });
          bonfire_federate_activitypub =
            previousMixPkgs.bonfire_federate_activitypub.overrideAttrs
              (previousMixPkg: {
                # Explanation: missing dependency in upstream's deps.git…
                postPatch = previousMixPkg.postPatch or "" + ''
                  cat >>deps.git <<EOF

                  bonfire_ui_common = "https://github.com/bonfire-networks/bonfire_ui_common"
                  EOF
                '';
              });
          bonfire_ui_common = previousMixPkgs.bonfire_ui_common.overrideAttrs (previousMixPkg: {
            postPatch =
              previousMixPkg.postPatch or ""
              + lib.concatStringsSep "\n" [
                # Explanation: fix dangling symlinks
                # Issue: https://github.com/bonfire-networks/bonfire_ui_common/issues/11
                ''
                  rm priv/static

                  test $(readlink assets/static/assets/ap_c2s_client) = extensions/bonfire_ui_common/assets/static/tauri/assets/ap_c2s_client
                  rm assets/static/assets/ap_c2s_client
                ''
                # ToDo(maint/update): adapt when fixed upstream
                ''
                  test $(readlink assets/static/assets/openmls) = /Users/me/Code/Bonfire/openmls/openmls-wasm/pkg
                  rm assets/static/assets/openmls
                ''
              ];
          });
          bonfire_ui_me = previousMixPkgs.bonfire_ui_me.overrideAttrs (previousMixPkg: {
            # Explanation: missing dependency in upstream's deps.hex…
            postPatch = previousMixPkg.postPatch or "" + ''
              cat >>deps.hex <<EOF

              absinthe_phoenix = ">= 0.0.0"
              EOF
            '';
          });
          ex_cldr = previousMixPkgs.ex_cldr.overrideAttrs (previousMixPkg: {
            # Explanation: use the GitHub sources instead of Hex,
            # as it otherwise tries to download the locales when building reverse-dependencies.
            src = fetchFromGitHub {
              owner = "elixir-cldr";
              repo = "cldr";
              rev = "v${previousMixPkg.version}";
              hash = lib.readFile (./extensions + "/${finalAttrs.env.FLAVOUR}/ex_cldr/fetchFromGitHub.hash");
            };
            postInstall = previousMixPkg.postInstall or "" + ''
              cp $src/priv/cldr/locales/* $out/lib/erlang/lib/ex_cldr-${previousMixPkg.version}/priv/cldr/locales/
            '';
            passthru = lib.recursiveUpdate previousMixPkg.passthru {
              # Description: update pkgs/by-name/bonfire/deps/ex_cldr/hash
              # Explanation: fetchFromGitHub is used instead of fetchHex
              # to let nix provision locales instead of mix.
              updateScript = writeShellApplication {
                name = "ex_cldr-update";
                runtimeInputs = [ nurl ];
                text = ''
                  mkdir -p pkgs/by-name/bonfire/extensions/${finalAttrs.env.FLAVOUR}/ex_cldr/
                  nurl --hash --expr 'let NGIpkgs = import ./. {}; in
                    NGIpkgs.bonfire.${finalAttrs.env.FLAVOUR}.passthru.mixNixDeps.ex_cldr.src.overrideAttrs (previousMixPkg:
                      { nativeBuildInputs = previousMixPkg.nativeBuildInputs or [] ++ [ NGIpkgs.pkgs.cacert ]; })
                  ' >pkgs/by-name/bonfire/extensions/${finalAttrs.env.FLAVOUR}/ex_cldr/fetchFromGitHub.hash
                '';
              };
            };
          });
          iconify_ex = previousMixPkgs.iconify_ex.overrideAttrs (previousMixPkg: {
            # Explanation: make iconify.ex look for its assets
            # in $out/assets/… instead of /build/source/assets/….
            postPatch = previousMixPkgs.postPatch or "" + ''
              substituteInPlace lib/iconify.ex \
                --replace-fail 'File.cwd!()' "\"$out\""
            '';
          });
          # Relevant: https://github.com/code-supply/deps_nix/pull/33
          lazy_html = previousMixPkgs.lazy_html.overrideAttrs (previousMixPkg: {
            # Explanation: somehow `mix compile --no-deps-check`
            # replaces Fine.include_dir() by "/build/fine-0.1.4/c_include"
            # a path which is not available when building lazy_html there.
            #
            # Explanation: lazy_html being built in a sandbox
            # it cannot download its precompiled binary,
            # it then attempt to compile from source by first git cloning lexbor,
            # but lexbor is already packaged in nixpkgs,
            # and to let the Makefile reuse it, it's enough to empty @lexbor_git_sha.
            postPatch = ''
              substituteInPlace mix.exs \
                --replace-fail "Fine.include_dir()" '"${finalMixPkgs.fine}/src/c_include"' \
                --replace-fail '@lexbor_git_sha "244b84956a6dc7eec293781d051354f351274c46"' '@lexbor_git_sha ""'
            '';

            # Explanation: workaround:
            # (File.Error) could not make directory (with -p) "/homeless-shelter/.cache/elixir_make":
            # no such file or directory
            preConfigure = previousMixPkg.preConfigure or "" + ''
              export ELIXIR_MAKE_CACHE_DIR="$TMPDIR/.cache"
            '';

            # Explanation: nix provides lexbor.
            preBuild = previousMixPkg.preBuild or "" + ''
              export LEXBOR_GIT_SHA=
              install -Dm644 \
                -t _build/c/third_party/lexbor/$LEXBOR_GIT_SHA/build \
                ${lexbor}/lib/liblexbor_static.a
            '';
            buildInputs = previousMixPkg.buildInputs or [ ] ++ [
              lexbor
            ];
          });
          # Explanation: somehow rustler is no longer tracked as a dependency
          # of rustler_precompiled in deps.nix, yet is required
          # to let Nix Nix provision Rust libraries:
          # Related: https://github.com/philss/rustler_precompiled/issues/71#issuecomment-2195460685
          rustler =
            let
              version = "0.37.1";
              drv = finalAttrs.passthru.beamPackages.buildMix {
                inherit version;
                name = "rustler";
                appConfigPath = ./config;

                src = finalAttrs.passthru.beamPackages.fetchHex {
                  inherit version;
                  pkg = "rustler";
                  sha256 = "24547e9b8640cf00e6a2071acb710f3e12ce0346692e45098d84d45cdb54fd79";
                };

                beamDeps = [
                  previousMixPkgs.jason
                ];
              };
            in
            drv;
          rustler_precompiled = previousMixPkgs.rustler_precompiled.overrideAttrs (previousMixPkg: {
            propagatedBuildInputs = previousMixPkg.propagatedBuildInputs or [ ] ++ [
              finalMixPkgs.rustler
            ];
          });
        }
        // lib.optionalAttrs (previousMixPkgs ? "evision") {
          evision = (callPackage deps/evision.nix { } finalMixPkgs previousMixPkgs).evision;
        }
        # Explanation: deps_nix wrongly detect rustler_precompiled is needed for flavours
        # and since it requires import-from-derivation,
        # they have to be removed from `preConfigure`.
        // lib.optionalAttrs (previousMixPkgs ? "ember") {
          ember = previousMixPkgs.ember.overrideAttrs { preConfigure = ""; };
        }
        // lib.optionalAttrs (previousMixPkgs ? "social") {
          social = previousMixPkgs.social.overrideAttrs { preConfigure = ""; };
        }
        // lib.optionalAttrs (previousMixPkgs ? "open_science") {
          open_science = previousMixPkgs.open_science.overrideAttrs { preConfigure = ""; };
        };
    };

    # Description: extensions used by `FLAVOUR`
    # computed by a closure over their dependencies.
    flavour-extensions = (
      let
        # Explanation: `src` may not exist yet due to
        urlAsKey = lib.map (ext: ext // { key = ext.name; });
      in
      builtins.genericClosure {
        startSet = urlAsKey [
          finalAttrs.passthru.extensions.${finalAttrs.env.FLAVOUR}
        ];
        operator = ext: urlAsKey ext.deps;
      }
    );
    extensions = {
      community = {
        name = "community";
        src = callPackage extensions/community/fetchFromGitHub.nix { };
        deps = with finalAttrs.passthru.extensions; [
          social
        ];
      };
      cooperation = {
        name = "cooperation";
        src = callPackage extensions/cooperation/fetchFromGitHub.nix { };
        deps = with finalAttrs.passthru.extensions; [
          ember
        ];
      };
      coordination = {
        name = "coordination";
        src = callPackage extensions/coordination/fetchFromGitHub.nix { };
        deps = with finalAttrs.passthru.extensions; [
          community
        ];
      };
      ember = {
        name = "ember";
        src = callPackage extensions/ember/fetchFromGitHub.nix { };
        deps = with finalAttrs.passthru.extensions; [ ];
      };
      open_science = {
        name = "open_science";
        src = callPackage extensions/open_science/fetchFromGitHub.nix { };
        deps = with finalAttrs.passthru.extensions; [
          social
        ];
      };
      social = {
        name = "social";
        src = callPackage extensions/social/fetchFromGitHub.nix { };
        deps = with finalAttrs.passthru.extensions; [
          ember
        ];
      };
    };

    yarnOfflineCaches =
      lib.genAttrs
        (lib.filter (pname: finalAttrs.passthru.mixNixDeps ? "${pname}") [
          "iconify_ex"
        ])
        (pname: {
          package = fetchYarnDeps {
            name = "${pname}-yarn-deps";
            yarnLock = "${finalAttrs.passthru.mixNixDeps.${pname}}/src/assets/yarn.lock";
            hash = lib.readFile (./extensions + "/${finalAttrs.env.FLAVOUR}/${pname}/yarnOfflineCache.hash");
          };
          updateScript = writeShellApplication {
            name = "${pname}-update";
            runtimeInputs = [ nurl ];
            text = ''
              set -eux
              mkdir -p "pkgs/by-name/bonfire/extensions/${finalAttrs.env.FLAVOUR}/${pname}/"
              nurl --hash --expr 'let NGIpkgs = import ./. {}; in
                NGIpkgs.bonfire.${finalAttrs.env.FLAVOUR}.yarnOfflineCaches.${pname}.package
              ' >'pkgs/by-name/bonfire/extensions/${finalAttrs.env.FLAVOUR}/${pname}/yarnOfflineCache.hash'
            '';
          };
        });
    yarn-berry = yarn-berry_4;
    yarnBerryOfflineCaches =
      lib.genAttrs
        (lib.filter (pname: finalAttrs.passthru.mixNixDeps ? "${pname}") [
          "bonfire_editor_milkdown"
          "bonfire_geolocate"
          "bonfire_ui_common"
        ])
        (pname: {

          package = finalAttrs.passthru.yarn-berry.fetchYarnBerryDeps {
            name = "${pname}-yarn-deps";
            yarnLock = "${finalAttrs.passthru.mixNixDeps.${pname}.src}/assets/yarn.lock";
            hash = lib.readFile (
              ./extensions + "/${finalAttrs.env.FLAVOUR}/${pname}/yarnBerryOfflineCache.hash"
            );
            missingHashes = ./extensions + "/${finalAttrs.env.FLAVOUR}/${pname}/missingHashes.json";
          };

          updateScript = writeShellApplication {
            name = "${pname}-update";
            runtimeInputs = [
              nix
              nurl
              finalAttrs.passthru.yarn-berry.yarn-berry-fetcher
            ];
            text = ''
              set -eux
              mkdir -p "pkgs/by-name/bonfire/extensions/${finalAttrs.env.FLAVOUR}/${pname}/"
              touch "pkgs/by-name/bonfire/extensions/${finalAttrs.env.FLAVOUR}/${pname}"/{yarnBerryOfflineCache.hash,missingHashes.json}
              nix -L --extra-experimental-features "nix-command" build --no-link -f . \
                "bonfire.${finalAttrs.env.FLAVOUR}.passthru.mixNixDeps.${pname}.src"
              yarnLock=$(nix -L --extra-experimental-features "nix-command" eval --raw -f . \
                "bonfire.${finalAttrs.env.FLAVOUR}.yarnBerryOfflineCaches.${pname}.package.yarnLock")
              yarn-berry-fetcher missing-hashes "$yarnLock" \
                >"pkgs/by-name/bonfire/extensions/${finalAttrs.env.FLAVOUR}/${pname}/missingHashes.json"
              nurl --expr "let NGIpkgs = import ./. {}; in
                NGIpkgs.bonfire.${finalAttrs.env.FLAVOUR}.yarnBerryOfflineCaches.${pname}.package
              " --hash >"pkgs/by-name/bonfire/extensions/${finalAttrs.env.FLAVOUR}/${pname}/yarnBerryOfflineCache.hash"
            '';
          };

        });

    # Warning(maint/update): bonfire having a huge dependency closure,
    # expect a lot of downloads during several minutes.
    # Besides, bonfire_social takes about one hour to update
    # because deps_nix needs to compile when updating…
    # and bonfire_social is notoriously slow to compile due to its GraphQL implementation.
    # Issue: https://github.com/bonfire-networks/bonfire-app/issues/1730
    update =
      callPackage ./update.nix {
        bonfire = bonfire.${finalAttrs.env.FLAVOUR};
      }
      // {
        after-mixNixDeps = writeShellApplication {
          name = "${finalAttrs.pname}-update";
          text = ''
            set -x
          ''
          + lib.concatLines (
            lib.concatMap
              (
                pkgs:
                lib.concatAttrValues (
                  lib.mapAttrs (name: pkg: lib.optional (pkg ? "updateScript") (lib.getExe pkg.updateScript)) pkgs
                )
              )
              (
                with finalAttrs.passthru;
                # Warning(correctness): the order matters
                # because `mixNixDeps`'s packages
                # can be used by the packages in yarn caches.
                [
                  mixNixDeps
                  yarnOfflineCaches
                  yarnBerryOfflineCaches
                ]
              )
          );
        };
      };

    # Explanation: to build its Erlang config (config/)
    # and some JavaScript imports (**/deps.hooks.js)
    # bonfire-app overlays symlinks from bonfire-app, ember and ${finalAttrs.env.FLAVOUR}.
    bonfire-setup =
      runCommandLocal "bonfire-setup"
        {
          inherit (finalAttrs) src;
          nativeBuildInputs = [
            just
          ];
        }
        (
          lib.concatStringsSep "\n" [
            ''
              set -eu -o pipefail
              mkdir $out
              cd $out
            ''

            # Explanation: reuse justfile's convoluted rules to merge configs.
            # Note that:
            # - libraries (eg. surface_from_helpers) want to replace files inside config/
            # - there are relative paths **inside** files (eg. ../../deps/… paths in **/deps.hook.js),
            # preventing the use of symlinks for them
            # because their path is canonicalized before including them,
            # so that cannot be a symlink pointing out of this setup…
            #
            # Note that `just _assets-ln` is not called,
            # since bonfire_ui_common has not been built yet,
            # assets/ will be set later when building the bonfire package with mixRelease.
            #
            # Note that some extensions (eg. open_science) do not have an assets/ directory
            # yet assets/hooks/ is required by surface_form_helpers.
            ''
              mkdir extensions
            ''
            (lib.concatMapStringsSep "\n" (ext: ''
              cp --no-preserve=mode -r ${ext.src} extensions/${ext.src.repo}
              mkdir -p extensions/${ext.src.repo}/assets/hooks
            '') finalAttrs.passthru.flavour-extensions)

            # ToDo(maintenance): remove when fixed upstream
            # https://github.com/bonfire-networks/ember/pull/2
            ''
              substituteInPlace extensions/ember/deps.git \
                --replace-fail '## GENERAL' 'bonfire_ui_reactions = "https://github.com/bonfire-networks/bonfire_ui_reactions"'
            ''

            ''
              cp --no-preserve=mode -r ${finalAttrs.src}/config .
              cp --no-preserve=mode -rs ${finalAttrs.src}/justfile .
              just flavour_make_symlinks ${finalAttrs.env.FLAVOUR}
            ''

            # Explanation: from: just _flavour_install
            ''
              $SHELL extensions/${finalAttrs.env.FLAVOUR}/install.sh --yes
            ''

            # Explanation: unsymlink config/config.exs to modify it
            ''
              cp --no-preserve=mode --remove-destination --force "$(realpath config/config.exs)" config/config.exs
            ''

            # Explanation: set skip_compilation? to let nix provide Rust libraries,
            # and load_from because rustler defaults to priv/native/#{crate}
            # but deps_nix installs into priv/native/lib#{crate}.
            #
            # Issue: https://github.com/code-supply/deps_nix/issues/36
            ''
              cat >>config/config.exs <<EOF

              config :lumis,
                      Lumis.Native,
                      skip_compilation?: true,
                      load_from: {:lumis, "priv/native/liblumis_nif"}
              config :decent,
                      Decent.Native,
                      skip_compilation?: true,
                      load_from: {:decent, "priv/native/libdecent"}
              config :mdex_native,
                      MDExNative.Native,
                      skip_compilation?: true,
                      load_from: {:mdex_native, "priv/native/libmdex_native_nif"}
              config :mjml,
                      Mjml.Native,
                      skip_compilation?: true,
                      load_from: {:mjml, "priv/native/libmjml_nif"}
              config :tokenizers,
                      Tokenizers.Native,
                      skip_compilation?: true,
                      load_from: {:tokenizers, "priv/native/libex_tokenizers"}
              EOF
            ''
          ]
        );

    beamPackages = beamPkgs // {
      buildMix =
        previousArgs:
        lib.makeOverridable beamPkgs.buildMix (
          #finalAttrs:
          previousArgs
          // {
            # Explanation: in some of its own dependencies,
            # bonfire uses Mess for managing dependencies,
            # which requires to vendor-in mess.exs,
            # but as of Bonfire 1.0.0 some are outdated wrt. bonfire-app/lib/mix/mess.exs
            # causing mix to fail hard… so, override globally without remorse.
            postPatch = previousArgs.postPatch or "" + ''
              if grep -qF Mess mix.exs; then
                ln -fns \${finalAttrs.src + "/lib/mix/mess.exs"} mess.exs
                # Explanation: some mix.exs depend on mess.exs but do not load it…
                sed -i mix.exs -e 's/^ *# *Code.eval_file(\"mess.exs\"/Code.eval_file(\"mess.exs\"/'
              fi
            '';

            # Explanation: get a writable extensions.
            # Because some dependencies generate files into them,
            # eg. surface_form_helpers generates into config/current_flavour/assets/hooks/
            # which points to extensions/social/assets/hooks/
            appConfigPath = "${finalAttrs.passthru.bonfire-setup}/config";

            # Because of surface.
            erlangDeterministicBuilds = false;

            # Explanation: inherit the environment variables
            # from bonfire because they're used in `appConfigPath`.
            env = finalAttrs.env // previousArgs.env or { };
            inherit (finalAttrs) mixEnv;
            postConfigure = previousArgs.postConfigure or "" + ''
              cp --no-preserve=mode -r ${finalAttrs.passthru.bonfire-setup}/extensions .
            '';
          }
        );
    };
  };
  mixEnv = "prod";
  # Explanation: incompatible with Surface.
  # Issue: https://github.com/surface-ui/surface/issues/762
  erlangDeterministicBuilds = false;

  # ToDo(optimize/size): test if it works.
  #stripDebug = true;

  nativeBuildInputs = [
    finalAttrs.passthru.yarn-berry.yarnBerryConfigHook
    yarnConfigHook
    nodejs
  ];

  # Explanation: to run yarnConfigHook multiple times manually.
  dontYarnInstallDeps = true;
  dontYarnBerryInstallDeps = true;

  patches = [
    patches/bumblebee.diff
  ];
  # FixMe(maintenance): version trimmed from ".alpha-1" suffix to avoid:
  # -> Running mix compile.app --no-deps-check (inside Bonfire.Umbrella.MixProject)
  # ** (Mix.Error) Expected :version to be a valid Version, got: "1.0.6.alpha-ember-1" (see the Version module for more information)
  #     (mix 1.18.4) lib/mix.ex:618: Mix.raise/2
  #     (mix 1.18.4) lib/mix/tasks/compile.app.ex:146: Mix.Tasks.Compile.App.run/1
  #     (mix 1.18.4) lib/mix/task.ex:495: anonymous fn/3 in Mix.Task.run_task/5
  #     (stdlib 6.2.2.3) timer.erl:595: :timer.tc/2
  #     (mix 1.18.4) lib/mix/task.ex:519: Mix.Task.with_debug/4
  #     (mix 1.18.4) lib/mix/tasks/compile.all.ex:117: Mix.Tasks.Compile.All.run_compiler/2
  #     (mix 1.18.4) lib/mix/tasks/compile.all.ex:97: Mix.Tasks.Compile.All.compile/4
  #     (mix 1.18.4) lib/mix/tasks/compile.all.ex:71: Mix.Tasks.Compile.All.do_run/2
  postPatch = ''
    substituteInPlace mix.exs \
      --replace-fail 'version: "1.0.6-beta.5"' 'version: "1.0.6"'
  '';

  postConfigure = lib.concatStringsSep "\n" [
    # Explanation: bonfire_ui_common & co. look like Elixir libraries,
    # but can only be built correctly inside bonfire-app.
    ''
      cp --no-preserve=mode -r ${finalAttrs.passthru.bonfire-setup}/* .
      mkdir -p extensions
      ln -s ../deps/bonfire_ui_common \
            extensions/bonfire_ui_common
      ln -s extensions/bonfire_ui_common/assets \
            assets
    ''

    # FixMe(functional/completeness): workaround
    # some settings have a different value during runtime compared to compile time,
    # at least :rustler_precompiled and :mime
    # Issue: https://github.com/bonfire-networks/bonfire-app/issues/1696
    ''
      cat >>config/runtime.exs <<EOF
        config :rustler_precompiled, force_build_all: true
      EOF
      substituteInPlace mix.exs \
        --replace-fail "runtime_config_path:" "validate_compile_env: false, runtime_config_path:"
    ''

    # Explanation: make runtime.exs configurable at runtime
    # (eg. in a NixOS module) without rebuilding the package.
    ''
      cat >>config/runtime.exs <<EOF
        config :rustler_precompiled, force_build_all: true
        Code.eval_file(System.get_env("BONFIRE_RUNTIME_CONFIG"))
      EOF
    ''

    # Explanation: from justfile#_deps-post-get
    ''
      mkdir -p data
      mkdir -p data/uploads
      mkdir -p priv/static/data
      (cd priv/static/data && ln -fns ../../../data/uploads)
    ''
  ];

  # Note: `preBuild` will not be used when updating,
  # hence it works to have finalAttrs.passthru.mixNixDeps.${dep}
  # in there because `deps.nix` will be updated by then.
  preBuild = lib.concatStringsSep "\n" [
    ''
      mkdir -p deps
    ''
    # Explanation: those yarn assets are not real libraries,
    # they can only be built in bonfire-app.
    # Explanation(correctness): /src is used instead of .src to be sure to have any patch applied.
    (lib.concatMapStringsSep "\n" (dep: ''
      rm -rf deps/${dep}
      cp --no-preserve=mode -r \
        ${finalAttrs.passthru.mixNixDeps.${dep}}/src \
        deps/${dep}
      pushd deps/${dep}/assets
      yarnOfflineCache="${finalAttrs.passthru.yarnOfflineCaches.${dep}.package}" \
      PATH="${lib.makeBinPath [ yarn ]}:$PATH" \
      yarnConfigHook
      popd
    '') (lib.attrNames finalAttrs.passthru.yarnOfflineCaches))

    # Explanation: same but for yarn-berry assets.
    # Note that /src is used instead of .src to be sure to have any patch applied.
    (lib.concatMapStringsSep "\n" (dep: ''
      rm -rf deps/${dep}
      cp --no-preserve=mode -r \
        ${finalAttrs.passthru.mixNixDeps.${dep}}/src \
        deps/${dep}
      pushd deps/${dep}/assets
      yarnOfflineCache="${finalAttrs.passthru.yarnBerryOfflineCaches.${dep}.package}" \
      missingHashes="${finalAttrs.passthru.yarnBerryOfflineCaches.${dep}.package.missingHashes}" \
      PATH="${lib.makeBinPath [ finalAttrs.passthru.yarn-berry.yarn-berry-offline ]}:$PATH" \
      yarnBerryConfigHook
      popd
    '') (lib.attrNames finalAttrs.passthru.yarnBerryOfflineCaches))

    # Explanation: call lib/mix/tasks/sync_themes.ex
    # See: justfile#_flavour_install ${finalAttrs.env.FLAVOUR}
    ''
      mix bonfire.sync_themes
    ''

    # Explanation: install SQL migrations.
    # See: justfile#_ext-migrations-copy
    # which calls:
    #
    # mix bonfire.install.copy_migrations --force
    #
    # implemented in deps/bonfire_common/lib/mix_tasks/install/
    # and callable with:
    #
    # Mix.Tasks.Bonfire.Install.CopyMigrations.copy_all(nil, [{:force, true}, {:to, "priv/repo/migrations/"}])
    #
    # But within the nix setup this fails without my knowing why
    # either by hanging when copying, or by not copying all migrations.
    # Note that all files are also copied, including those with *.exs.wip.
    ''
      rm -rf priv/repo/*
      mkdir -p priv/repo/migrations/
      for file in _build/${finalAttrs.mixEnv}/lib/bonfire_*/priv/repo/migrations/*; do
        cp -ft priv/repo/migrations/ "$file"
      done
    ''
  ];

  postBuild = lib.concatStringsSep "\n" [
    # See: justfile#_rel-compile-assets
    ''
      mix bonfire.gen_tailwind_sources
      ln -fns ${finalAttrs.passthru.mixNixDeps.phoenix}/src deps/phoenix
      ln -fns ${finalAttrs.passthru.mixNixDeps.phoenix_live_view}/src deps/phoenix_live_view
      ln -fns ${finalAttrs.passthru.mixNixDeps.phoenix_html}/src deps/phoenix_html
      ln -fns ${finalAttrs.passthru.mixNixDeps.phoenix_live_head}/src deps/phoenix_live_head
      ln -fns ${finalAttrs.passthru.mixNixDeps.bonfire_notify}/src deps/bonfire_notify
      ln -fns ${finalAttrs.passthru.mixNixDeps.live_select}/src deps/live_select
      ln -fns ${finalAttrs.passthru.mixNixDeps.bonfire_ui_reactions}/src deps/bonfire_ui_reactions
      pushd assets
      ${lib.getExe finalAttrs.passthru.yarn-berry.yarn-berry-offline} build
      popd
      if [ -d "extensions/${finalAttrs.env.FLAVOUR}/priv/static" ]; then
        cp -R "extensions/${finalAttrs.env.FLAVOUR}/priv/static/." priv/static/
      fi
      mix phx.digest --no-deps-check
    ''
  ];

  preInstall = lib.concatStringsSep "\n" [
    ''
      cp -ra ${finalAttrs.passthru.mixNixDeps.exla}/cache cache
    ''
  ];

  # Explanation: only concern buildtime debugging,
  # by being more verbose about what mixRelease
  # and mix do (through MIX_DEBUG=1).
  enableDebugInfo = true;

  meta = {
    description = "An open-source framework for building federated digital spaces where people can gather, interact, and form communities online";
    homepage = "https://bonfirenetworks.org";
    license = with lib.licenses; [
      agpl3Only
      cc0
    ];
    maintainers = with lib.maintainers; [ julm ];
    teams = [ lib.teams.ngi ];
    mainProgram = "bonfire";
  };
})
