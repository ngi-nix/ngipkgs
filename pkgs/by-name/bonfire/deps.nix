{
  pkgs,
  lib,
  beamPackages,
  overrides ? (x: y: { }),
  overrideFenixOverlay ? null,
}:

let
  buildMix = lib.makeOverridable beamPackages.buildMix;
  buildRebar3 = lib.makeOverridable beamPackages.buildRebar3;

  workarounds = {
    portCompiler = _unusedArgs: old: {
      buildPlugins = [ pkgs.beamPackages.pc ];
    };

    rustlerPrecompiled =
      {
        toolchain ? null,
        ...
      }:
      old:
      let
        extendedPkgs = pkgs.extend fenixOverlay;
        fenixOverlay =
          if overrideFenixOverlay == null then
            import "${
              fetchTarball {
                url = "https://github.com/nix-community/fenix/archive/056c9393c821a4df356df6ce7f14c722dc8717ec.tar.gz";
                sha256 = "sha256:1cdfh6nj81gjmn689snigidyq7w98gd8hkl5rvhly6xj7vyppmnd";
              }
            }/overlay.nix"
          else
            overrideFenixOverlay;
        nativeDir = "${old.src}/native/${with builtins; head (attrNames (readDir "${old.src}/native"))}";
        fenix =
          if toolchain == null then
            extendedPkgs.fenix.stable
          else
            extendedPkgs.fenix.fromToolchainName toolchain;
        native =
          (extendedPkgs.makeRustPlatform {
            inherit (fenix) cargo rustc;
          }).buildRustPackage
            {
              pname = "${old.packageName}-native";
              version = old.version;
              src = nativeDir;
              cargoLock = {
                lockFile = "${nativeDir}/Cargo.lock";
              };
              nativeBuildInputs = [
                extendedPkgs.cmake
              ];
              doCheck = false;
            };

      in
      {
        nativeBuildInputs = [ extendedPkgs.cargo ];

        env.RUSTLER_PRECOMPILED_FORCE_BUILD_ALL = "true";
        env.RUSTLER_PRECOMPILED_GLOBAL_CACHE_PATH = "unused-but-required";

        preConfigure = ''
          mkdir -p priv/native
          for lib in ${native}/lib/*
          do
            ln -s "$lib" "priv/native/$(basename "$lib")"
          done
        '';

        buildPhase = ''
          suggestion() {
            echo "***********************************************"
            echo "                 deps_nix                      "
            echo
            echo " Rust dependency build failed.                 "
            echo
            echo " If you saw network errors, you might need     "
            echo " to disable compilation on the appropriate     "
            echo " RustlerPrecompiled module in your             "
            echo " application config.                           "
            echo
            echo " We think you need this:                       "
            echo
            echo -n " "
            grep -Rl 'use RustlerPrecompiled' lib \
              | xargs grep 'defmodule' \
              | sed 's/defmodule \(.*\) do/config :${old.packageName}, \1, skip_compilation?: true/'
            echo "***********************************************"
            exit 1
          }
          trap suggestion ERR
          ${old.buildPhase}
        '';
      };

    elixirMake = _unusedArgs: old: {
      preConfigure = ''
        export ELIXIR_MAKE_CACHE_DIR="$TEMPDIR/elixir_make_cache"
      '';
    };

    lazyHtml = _unusedArgs: old: {
      preConfigure = ''
        export ELIXIR_MAKE_CACHE_DIR="$TEMPDIR/elixir_make_cache"
      '';

      postPatch = ''
        substituteInPlace mix.exs           --replace-fail "Fine.include_dir()" '"${packages.fine}/src/c_include"'           --replace-fail '@lexbor_git_sha "244b84956a6dc7eec293781d051354f351274c46"' '@lexbor_git_sha ""'
      '';

      preBuild = ''
        install -Dm644           -t _build/c/third_party/lexbor/$LEXBOR_GIT_SHA/build           ${pkgs.lexbor}/lib/liblexbor_static.a
      '';
    };
  };

  defaultOverrides = (
    final: prev:

    let
      apps = {
        crc32cer = [
          {
            name = "portCompiler";
          }
        ];
        explorer = [
          {
            name = "rustlerPrecompiled";
            toolchain = {
              name = "nightly-2024-11-01";
              sha256 = "sha256-wq7bZ1/IlmmLkSa3GUJgK17dTWcKyf5A+ndS9yRwB88=";
            };
          }
        ];
        snappyer = [
          {
            name = "portCompiler";
          }
        ];
      };

      applyOverrides =
        appName: drv:
        let
          allOverridesForApp = builtins.foldl' (
            acc: workaround: acc // (workarounds.${workaround.name} workaround) drv
          ) { } apps.${appName};

        in
        if builtins.hasAttr appName apps then drv.override allOverridesForApp else drv;

    in
    builtins.mapAttrs applyOverrides prev
  );

  self = packages // (defaultOverrides self packages) // (overrides self packages);

  packages =
    with beamPackages;
    with self;
    {

      absinthe =
        let
          version = "1.7.10";
          drv = buildMix {
            inherit version;
            name = "absinthe";
            appConfigPath = ./config;

            src = fetchHex {
              inherit version;
              pkg = "absinthe";
              sha256 = "ffda95735364c041a65a4b0e02ffb04eabb1e52ab664fa7eeecefb341449e8c2";
            };

            beamDeps = [
              dataloader
              decimal
              nimble_parsec
              opentelemetry_process_propagator
              telemetry
            ];
          };
        in
        drv;

      absinthe_client =
        let
          version = "2.0.0";
          drv = buildMix {
            inherit version;
            name = "absinthe_client";
            appConfigPath = ./config;

            src = pkgs.fetchFromGitHub {
              owner = "bonfire-networks";
              repo = "absinthe_client";
              rev = "ceeb7c3bb8ac5348c399653a06eaaee3bbd47d8f";
              hash = "sha256-WBMtr2d56eYc3FdTtljzo9IzBPGVllVsOyYe+oqxoaI=";
            };

            beamDeps = [
              absinthe_plug
              absinthe
              decimal
              phoenix
              phoenix_pubsub
              phoenix_html
              phoenix_live_view
            ];
          };
        in
        drv;

      absinthe_error_payload =
        let
          version = "1.2.0";
          drv = buildMix {
            inherit version;
            name = "absinthe_error_payload";
            appConfigPath = ./config;

            src = fetchHex {
              inherit version;
              pkg = "absinthe_error_payload";
              sha256 = "d9b9201a2710a2c09da7a5a35a2d8aff0b0c9253875ab629c45747e13f4b1e4a";
            };

            beamDeps = [
              absinthe
              ecto
            ];
          };
        in
        drv;

      absinthe_phoenix =
        let
          version = "2.0.3";
          drv = buildMix {
            inherit version;
            name = "absinthe_phoenix";
            appConfigPath = ./config;

            src = fetchHex {
              inherit version;
              pkg = "absinthe_phoenix";
              sha256 = "caffaea03c17ea7419fe07e4bc04c2399c47f0d8736900623dbf4749a826fd2c";
            };

            beamDeps = [
              absinthe
              absinthe_plug
              decimal
              phoenix
              phoenix_html
              phoenix_pubsub
            ];
          };
        in
        drv;

      absinthe_plug =
        let
          version = "1.5.9";
          drv = buildMix {
            inherit version;
            name = "absinthe_plug";
            appConfigPath = ./config;

            src = fetchHex {
              inherit version;
              pkg = "absinthe_plug";
              sha256 = "dcdc84334b0e9e2cd439bd2653678a822623f212c71088edf0a4a7d03f1fa225";
            };

            beamDeps = [
              absinthe
              plug
            ];
          };
        in
        drv;

      absinthe_relay =
        let
          version = "1.5.2";
          drv = buildMix {
            inherit version;
            name = "absinthe_relay";
            appConfigPath = ./config;

            src = fetchHex {
              inherit version;
              pkg = "absinthe_relay";
              sha256 = "0587ee913afa31512e1457a5064ee88427f8fe7bcfbeeecd41c71d9cff0b62b6";
            };

            beamDeps = [
              absinthe
              ecto
            ];
          };
        in
        drv;

      acceptor_pool =
        let
          version = "1.0.0";
          drv = buildRebar3 {
            inherit version;
            name = "acceptor_pool";

            src = fetchHex {
              inherit version;
              pkg = "acceptor_pool";
              sha256 = "0cbcd83fdc8b9ad2eee2067ef8b91a14858a5883cb7cd800e6fcd5803e158788";
            };
          };
        in
        drv;

      accessible =
        let
          version = "0.3.0";
          drv = buildMix {
            inherit version;
            name = "accessible";
            appConfigPath = ./config;

            src = fetchHex {
              inherit version;
              pkg = "accessible";
              sha256 = "13a11b0611ab82f7b9098a88465b5674f729c02bd613216243c123c65f90f296";
            };
          };
        in
        drv;

      activity_pub =
        let
          version = "0.1.0";
          drv = buildMix {
            inherit version;
            name = "activity_pub";
            appConfigPath = ./config;

            src = pkgs.fetchFromGitHub {
              owner = "bonfire-networks";
              repo = "activity_pub";
              rev = "b09d2412ec16dc352c513f96c044740719ba8b9f";
              hash = "sha256-IChQwIgeJuycZns/1lVqkF4ZadJNvQMWcapVR3a5Qhw=";
            };

            beamDeps = [
              phoenix
              plug_cowboy
              phoenix_ecto
              phoenix_live_dashboard
              phoenix_html_helpers
              ecto_sql
              postgrex
              telemetry_metrics
              telemetry_poller
              jason
              mime
              oban
              tesla
              http_signatures
              mfm_parser
              remote_ip
              hammer
              cachex
              plug_http_validator
              needle_uid
              arrows
              untangle
            ];
          };
        in
        drv;

      argon2_elixir =
        let
          version = "4.1.3";
          drv = buildMix {
            inherit version;
            name = "argon2_elixir";
            appConfigPath = ./config;

            src = fetchHex {
              inherit version;
              pkg = "argon2_elixir";
              sha256 = "7c295b8d8e0eaf6f43641698f962526cdf87c6feb7d14bd21e599271b510608c";
            };

            beamDeps = [
              comeonin
              elixir_make
            ];
          };
        in
        drv.override (workarounds.elixirMake { } drv);

      arrows =
        let
          version = "0.2.1";
          drv = buildMix {
            inherit version;
            name = "arrows";
            appConfigPath = ./config;

            src = fetchHex {
              inherit version;
              pkg = "arrows";
              sha256 = "c3de1ba8f2fd79782bce66d601e6aeded1bcb67e4190858e51da4fe3684ffb9d";
            };
          };
        in
        drv;

      astro =
        let
          version = "1.1.2";
          drv = buildMix {
            inherit version;
            name = "astro";
            appConfigPath = ./config;

            src = fetchHex {
              inherit version;
              pkg = "astro";
              sha256 = "b82204ade17ec730b13b4d7a163bf204ec9ddeff77147afda032726539644c7f";
            };

            beamDeps = [
              geo
              tz_world
              tzdata
            ];
          };
        in
        drv;

      autumn =
        let
          version = "0.5.2";
          drv = buildMix {
            inherit version;
            name = "autumn";
            appConfigPath = ./config;

            src = fetchHex {
              inherit version;
              pkg = "autumn";
              sha256 = "83dd42823f91ff97ea91fba3dac62f1ffce384b2b43c8db3b5a73108d6a8cad3";
            };

            beamDeps = [
              nimble_options
              rustler
              rustler_precompiled
            ];
          };
        in
        drv.override (workarounds.rustlerPrecompiled { } drv);

      bamboo =
        let
          version = "2.5.0";
          drv = buildMix {
            inherit version;
            name = "bamboo";
            appConfigPath = ./config;

            src = fetchHex {
              inherit version;
              pkg = "bamboo";
              sha256 = "35c8635ff6677a81ab7258944ff15739280f3254a041b6f0229dddeb9b90ad3d";
            };

            beamDeps = [
              hackney
              jason
              mime
              plug
            ];
          };
        in
        drv;

      bamboo_campaign_monitor =
        let
          version = "0.1.0";
          drv = buildMix {
            inherit version;
            name = "bamboo_campaign_monitor";
            appConfigPath = ./config;

            src = fetchHex {
              inherit version;
              pkg = "bamboo_campaign_monitor";
              sha256 = "5b60a27ab2b8596f274f22d3cb8bd8d8f3865667f1ec181bfa6635aa7646d79a";
            };

            beamDeps = [
              bamboo
              hackney
              plug
            ];
          };
        in
        drv;

      bamboo_mailjet =
        let
          version = "0.1.0";
          drv = buildMix {
            inherit version;
            name = "bamboo_mailjet";
            appConfigPath = ./config;

            src = fetchHex {
              inherit version;
              pkg = "bamboo_mailjet";
              sha256 = "cb213439a14dfe0f8a54dbcb7b40790399d5207025378b64d9717271072e8427";
            };

            beamDeps = [
              bamboo
            ];
          };
        in
        drv;

      bamboo_postmark =
        let
          version = "1.0.0";
          drv = buildMix {
            inherit version;
            name = "bamboo_postmark";
            appConfigPath = ./config;

            src = fetchHex {
              inherit version;
              pkg = "bamboo_postmark";
              sha256 = "443b3fb9e00a5d092ccfc91cfe3dbecab2a931114d4dc5e1e70f28f6c640c63d";
            };

            beamDeps = [
              bamboo
              hackney
              plug
            ];
          };
        in
        drv;

      bamboo_sendcloud =
        let
          version = "0.2.0";
          drv = buildMix {
            inherit version;
            name = "bamboo_sendcloud";
            appConfigPath = ./config;

            src = fetchHex {
              inherit version;
              pkg = "bamboo_sendcloud";
              sha256 = "37e35b408394f1be2f3cefb3fd3064527e92bfd8e6e5a546aaad705f105b405a";
            };

            beamDeps = [
              bamboo
              hackney
              plug
              poison
            ];
          };
        in
        drv;

      bamboo_ses =
        let
          version = "0.4.5";
          drv = buildMix {
            inherit version;
            name = "bamboo_ses";
            appConfigPath = ./config;

            src = fetchHex {
              inherit version;
              pkg = "bamboo_ses";
              sha256 = "ea3e82b35a7a255690753824392e8eb25f5bf884cfec416deb9a81bbeb1b503b";
            };

            beamDeps = [
              bamboo
              ex_aws
              gen_smtp
              jason
            ];
          };
        in
        drv;

      bamboo_smtp =
        let
          version = "4.2.2";
          drv = buildMix {
            inherit version;
            name = "bamboo_smtp";
            appConfigPath = ./config;

            src = fetchHex {
              inherit version;
              pkg = "bamboo_smtp";
              sha256 = "28cac2ec8adaae02aed663bf68163992891a3b44cfd7ada0bebe3e09bed7207f";
            };

            beamDeps = [
              bamboo
              gen_smtp
            ];
          };
        in
        drv;

      bamboo_sparkpost =
        let
          version = "2.0.0";
          drv = buildMix {
            inherit version;
            name = "bamboo_sparkpost";
            appConfigPath = ./config;

            src = fetchHex {
              inherit version;
              pkg = "bamboo_sparkpost";
              sha256 = "a89a1c29e122270e50c53c77e091d885c40bebb689f8904572c38b299649bebf";
            };

            beamDeps = [
              bamboo
            ];
          };
        in
        drv;

      bandit =
        let
          version = "1.8.0";
          drv = buildMix {
            inherit version;
            name = "bandit";
            appConfigPath = ./config;

            src = fetchHex {
              inherit version;
              pkg = "bandit";
              sha256 = "8458ff4eed20ff2a2ea69d4854883a077c33ea42b51f6811b044ceee0fa15422";
            };

            beamDeps = [
              hpax
              plug
              telemetry
              thousand_island
              websock
            ];
          };
        in
        drv;

      beam_file =
        let
          version = "0.6.2";
          drv = buildMix {
            inherit version;
            name = "beam_file";
            appConfigPath = ./config;

            src = fetchHex {
              inherit version;
              pkg = "beam_file";
              sha256 = "09a99e8e5aad674edcad7213b0d7602375dfd3c7d02f8e3136e3efae0bcc9c56";
            };
          };
        in
        drv;

      benchee =
        let
          version = "1.4.0";
          drv = buildMix {
            inherit version;
            name = "benchee";
            appConfigPath = ./config;

            src = fetchHex {
              inherit version;
              pkg = "benchee";
              sha256 = "299cd10dd8ce51c9ea3ddb74bb150f93d25e968f93e4c1fa31698a8e4fa5d715";
            };

            beamDeps = [
              deep_merge
              statistex
            ];
          };
        in
        drv;

      blurhash =
        let
          version = "0.1.0";
          drv = buildMix {
            inherit version;
            name = "blurhash";
            appConfigPath = ./config;

            src = fetchHex {
              inherit version;
              pkg = "rinpatch_blurhash";
              sha256 = "19911a5dcbb0acb9710169a72f702bce6cb048822b12de566ccd82b2cc42b907";
            };

            beamDeps = [
              mogrify
            ];
          };
        in
        drv;

      boltx =
        let
          version = "0.0.6";
          drv = buildMix {
            inherit version;
            name = "boltx";
            appConfigPath = ./config;

            src = fetchHex {
              inherit version;
              pkg = "boltx";
              sha256 = "576b8f21a2021674130d04cd1fc79a4829a23d2cdf50641b3d7a00ce31b98ead";
            };

            beamDeps = [
              db_connection
              jason
              poison
            ];
          };
        in
        drv;

      bonfire_api_graphql =
        let
          version = "0.2.0";
          drv = buildMix {
            inherit version;
            name = "bonfire_api_graphql";
            appConfigPath = ./config;

            src = pkgs.fetchFromGitHub {
              owner = "bonfire-networks";
              repo = "bonfire_api_graphql";
              rev = "75727b997ca820010541bc4e488762ccaccb5f91";
              hash = "sha256-bagP0fsjNrU6heJg/N/0K+mrAtGzSQFWE0mil/boz50=";
            };

            beamDeps = [
              bonfire_common
              bonfire_ui_common
              absinthe_client
              jason
              redirect
              absinthe
              absinthe_plug
              absinthe_error_payload
              absinthe_phoenix
              geo
              zest
              dataloader
              absinthe_relay
            ];
          };
        in
        drv;

      bonfire_boundaries =
        let
          version = "0.1.0";
          drv = buildMix {
            inherit version;
            name = "bonfire_boundaries";
            appConfigPath = ./config;

            src = pkgs.fetchFromGitHub {
              owner = "bonfire-networks";
              repo = "bonfire_boundaries";
              rev = "de3688249310b8651e3a5de5264cb9fe8d5baa88";
              hash = "sha256-ulUke0u5UOrq9s+dS5DyoHXwvqGP1aRKWx002JmctxM=";
            };

            beamDeps = [
              bonfire_common
              bonfire_epics
              bonfire_data_access_control
              faker
              jason
              scribe
              needle
              ecto_vista
              igniter
            ];
          };
        in
        drv;

      bonfire_classify =
        let
          version = "0.1.0";
          drv = buildMix {
            inherit version;
            name = "bonfire_classify";
            appConfigPath = ./config;

            src = pkgs.fetchFromGitHub {
              owner = "bonfire-networks";
              repo = "bonfire_classify";
              rev = "86d23fab2aad8d08618068237f3aa01231a67a3f";
              hash = "sha256-b5C9+Bnrd8oIVNDc0f2XNho6GVE6wimnzNgKF7Pptjs=";
            };

            beamDeps = [
              bonfire_common
              bonfire_tag
              faker
              jason
              telemetry_metrics
              telemetry_poller
              needle
              absinthe
              bonfire_api_graphql
              bonfire_search
              bonfire_me
            ];
          };
        in
        drv;

      bonfire_common =
        let
          version = "0.1.0";
          drv = buildMix {
            inherit version;
            name = "bonfire_common";
            appConfigPath = ./config;

            src = pkgs.fetchFromGitHub {
              owner = "bonfire-networks";
              repo = "bonfire_common";
              rev = "0ebdc702ce7a9cc7b5121cafe163b3b5b4e4bf13";
              hash = "sha256-GDf8qumU6sgseyVqyNNCXwH+bWt/ZvAynDechKhVpxg=";
            };

            beamDeps = [
              bonfire_data_identity
              paginator
              ecto_shorts
              exkismet
              needle_uid
              needle
              arrows
              untangle
              ecto_sparkles
              ecto_sql
              needle_ulid
              postgrex
              gettext
              ex_cldr
              ex_cldr_languages
              ex_cldr_plugs
              ex_cldr_dates_times
              ex_cldr_units
              ex_cldr_numbers
              ex_cldr_locale_display
              ex_cldr_territories
              timex
              recase
              simple_slug
              tesla
              pathex
              json_serde
              jason
              mdex
              lazy_html
              html_sanitize_ex
              sizeable
              want
              opentelemetry_api
              git_diff
              beam_file
              faker
              process_tree
              nebulex
              zest
              sentry
              dataloader
              floki
              emote
              text
              text_corpus_udhr
              telemetry_metrics
              igniter
            ];
          };
        in
        drv;

      bonfire_data_access_control =
        let
          version = "0.1.0";
          drv = buildMix {
            inherit version;
            name = "bonfire_data_access_control";
            appConfigPath = ./config;

            src = pkgs.fetchFromGitHub {
              owner = "bonfire-networks";
              repo = "bonfire_data_access_control";
              rev = "9994601d8256aaf3cd35aabdeded94f2366b84ea";
              hash = "sha256-z1cLKd8zZxmaPaVzH4UsWpZ4VmXYvzxMwOuvWyga/fc=";
            };

            beamDeps = [
              needle
            ];
          };
        in
        drv;

      bonfire_data_activity_pub =
        let
          version = "0.1.0";
          drv = buildMix {
            inherit version;
            name = "bonfire_data_activity_pub";
            appConfigPath = ./config;

            src = pkgs.fetchFromGitHub {
              owner = "bonfire-networks";
              repo = "bonfire_data_activity_pub";
              rev = "3cf9cc7db3fc229c6949ee3fb415aa5524633daa";
              hash = "sha256-PS9w5D1kY95S1WVSJi+JDfrQc6txW1Xd0ud9KgWyzfU=";
            };

            beamDeps = [
              untangle
              needle
            ];
          };
        in
        drv;

      bonfire_data_assort =
        let
          version = "0.1.0";
          drv = buildMix {
            inherit version;
            name = "bonfire_data_assort";
            appConfigPath = ./config;

            src = pkgs.fetchFromGitHub {
              owner = "bonfire-networks";
              repo = "bonfire_data_assort";
              rev = "e3457b7048eb659c226a89142edaeb19f31fcb25";
              hash = "sha256-hmqkug0NJwVJfIRUy3eeiZnLrk2JQOH92b2PMmD2yiQ=";
            };

            beamDeps = [
              needle
              ecto_ranked
            ];
          };
        in
        drv;

      bonfire_data_edges =
        let
          version = "0.1.0";
          drv = buildMix {
            inherit version;
            name = "bonfire_data_edges";
            appConfigPath = ./config;

            src = pkgs.fetchFromGitHub {
              owner = "bonfire-networks";
              repo = "bonfire_data_edges";
              rev = "bb581f89e1a03cd3a74766676c3eebb2d56cee58";
              hash = "sha256-ypB+w0ByB3vkNpmcecW22QdAFYjrxUXpU6RpXdh2w2U=";
            };

            beamDeps = [
              needle
            ];
          };
        in
        drv;

      bonfire_data_identity =
        let
          version = "0.1.0";
          drv = buildMix {
            inherit version;
            name = "bonfire_data_identity";
            appConfigPath = ./config;

            src = pkgs.fetchFromGitHub {
              owner = "bonfire-networks";
              repo = "bonfire_data_identity";
              rev = "6207885e94c7426a2b5295aeaf85223eacc71078";
              hash = "sha256-S0qaRCRx/HiC+xn3qzKTWugChbJZwBnCgk8/E4afNPU=";
            };

            beamDeps = [
              bonfire_data_edges
              needle
              untangle
              ecto_sparkles
              json_serde
            ];
          };
        in
        drv;

      bonfire_data_shared_user =
        let
          version = "0.1.0";
          drv = buildMix {
            inherit version;
            name = "bonfire_data_shared_user";
            appConfigPath = ./config;

            src = pkgs.fetchFromGitHub {
              owner = "bonfire-networks";
              repo = "bonfire_data_shared_user";
              rev = "dafbbe2ea65bb55599d774ef0f8a375179ac81b0";
              hash = "sha256-ksr6Hn2JKxBU6Zxoyr0Z/f1z/8Ow/jl/nblKIxAkmZY=";
            };

            beamDeps = [
              needle
              bonfire_data_identity
            ];
          };
        in
        drv;

      bonfire_data_social =
        let
          version = "0.1.0";
          drv = buildMix {
            inherit version;
            name = "bonfire_data_social";
            appConfigPath = ./config;

            src = pkgs.fetchFromGitHub {
              owner = "bonfire-networks";
              repo = "bonfire_data_social";
              rev = "deaddb549a4313a2bad412b23c4f5249be7a07d6";
              hash = "sha256-MHPlq4XLw8fvlUwaxAZ3kyIbzGisz9IAAzWzDNF4ZGs=";
            };

            beamDeps = [
              bonfire_data_edges
              ecto_materialized_path
              arrows
              untangle
              needle
            ];
          };
        in
        drv;

      bonfire_ecto =
        let
          version = "0.1.0";
          drv = buildMix {
            inherit version;
            name = "bonfire_ecto";
            appConfigPath = ./config;

            src = pkgs.fetchFromGitHub {
              owner = "bonfire-networks";
              repo = "bonfire_ecto";
              rev = "fd567fd674b286400d457415698f089027118751";
              hash = "sha256-lRZt3gdHar2Gt1+p1vYhWP8DfhiHbNjyKahgrxKPNlM=";
            };

            beamDeps = [
              bonfire_common
              bonfire_epics
            ];
          };
        in
        drv;

      bonfire_editor_milkdown =
        let
          version = "0.0.1";
          drv = buildMix {
            inherit version;
            name = "bonfire_editor_milkdown";
            appConfigPath = ./config;

            src = pkgs.fetchFromGitHub {
              owner = "bonfire-networks";
              repo = "bonfire_editor_milkdown";
              rev = "9baed6adee12661a46ec2c4adacd8b75e9cb0191";
              hash = "sha256-QTQbOow+GndRnXhZ9Gg7kkMvjly9VJb4ousBP3WCwCw=";
            };

            beamDeps = [
              bonfire_common
              bonfire_ui_common
              surface
              untangle
            ];
          };
        in
        drv;

      bonfire_epics =
        let
          version = "0.1.0";
          drv = buildMix {
            inherit version;
            name = "bonfire_epics";
            appConfigPath = ./config;

            src = pkgs.fetchFromGitHub {
              owner = "bonfire-networks";
              repo = "bonfire_epics";
              rev = "365fc195158b33d19aa386ceb7d0b1e25237049a";
              hash = "sha256-FzMyhqhMzHKsqsQ6Ujb/i6wOn7lNETvPfC/SJH3xCfg=";
            };

            beamDeps = [
              untangle
              arrows
              bonfire_common
            ];
          };
        in
        drv;

      bonfire_fail =
        let
          version = "0.1.0";
          drv = buildMix {
            inherit version;
            name = "bonfire_fail";
            appConfigPath = ./config;

            src = pkgs.fetchFromGitHub {
              owner = "bonfire-networks";
              repo = "bonfire_fail";
              rev = "80282fcdad3bdf8b4cdce347bc344aa5776c697d";
              hash = "sha256-/vWb6RP3l1oR5AM+mzvEFhgHgj81uBRGSIHJbjNvU44=";
            };

            beamDeps = [
              bonfire_common
              untangle
            ];
          };
        in
        drv;

      bonfire_federate_activitypub =
        let
          version = "0.1.0";
          drv = buildMix {
            inherit version;
            name = "bonfire_federate_activitypub";
            appConfigPath = ./config;

            src = pkgs.fetchFromGitHub {
              owner = "bonfire-networks";
              repo = "bonfire_federate_activitypub";
              rev = "3154c2fd06f8bb5bf92151f90af859e0966eb9d7";
              hash = "sha256-jZb8/mwWVb44eN54DyBe5/AaCJndF5istQKIaBpkVTY=";
            };

            beamDeps = [
              bonfire_common
              bonfire_me
              bonfire_social
              activity_pub
              nodeinfo
              faker
              gettext
              jason
              telemetry_metrics
              telemetry_poller
              oban
              untangle
              needle
              bonfire_boundaries
            ];
          };
        in
        drv;

      bonfire_files =
        let
          version = "0.1.0";
          drv = buildMix {
            inherit version;
            name = "bonfire_files";
            appConfigPath = ./config;

            src = pkgs.fetchFromGitHub {
              owner = "bonfire-networks";
              repo = "bonfire_files";
              rev = "22d2ce1ded99a7a3d7066220704cea3be0a64086";
              hash = "sha256-m5fe46k0NyzoYPVE+5M07ztxwX29WqlnHCGgAzgmcgg=";
            };

            beamDeps = [
              bonfire_common
              bonfire_ui_common
              bonfire_epics
              twinkle_star
              unfurl
              entrepot
              entrepot_ecto
              waffle
              ex_aws_sts
              mogrify
              hackney
              sweet_xml
              untangle
              needle
              sizeable
              faviconic
              bonfire_api_graphql
              image
              evision
              ex_aws_s3
              blurhash
            ];
          };
        in
        drv;

      bonfire_geolocate =
        let
          version = "0.1.0";
          drv = buildMix {
            inherit version;
            name = "bonfire_geolocate";
            appConfigPath = ./config;

            src = pkgs.fetchFromGitHub {
              owner = "bonfire-networks";
              repo = "bonfire_geolocate";
              rev = "a3a379f05d46a69617a3f9461a11312b7bc6bf26";
              hash = "sha256-NUEOiHWtZPEBrROLashbP0xNoHqtYl5udCj6LIdmOUc=";
            };

            beamDeps = [
              bonfire_common
              phoenix_gon
              faker
              jason
              telemetry_metrics
              telemetry_poller
              geocoder
              geo_postgis
              astro
              untangle
              needle
              tz_world
              absinthe
              bonfire_api_graphql
              bonfire_tag
            ];
          };
        in
        drv;

      bonfire_invite_links =
        let
          version = "0.0.1";
          drv = buildMix {
            inherit version;
            name = "bonfire_invite_links";
            appConfigPath = ./config;

            src = pkgs.fetchFromGitHub {
              owner = "bonfire-networks";
              repo = "bonfire_invite_links";
              rev = "cdacf1f5938248f1193a2d29e9154e77f0d792ad";
              hash = "sha256-SDb9bcJSJmddrEgTsVgGnaKE42n90d29od3sET7OiVw=";
            };

            beamDeps = [
              bonfire_common
              bonfire_ui_common
              faker
              jason
              untangle
              needle
            ];
          };
        in
        drv;

      bonfire_mailer =
        let
          version = "0.1.0";
          drv = buildMix {
            inherit version;
            name = "bonfire_mailer";
            appConfigPath = ./config;

            src = pkgs.fetchFromGitHub {
              owner = "bonfire-networks";
              repo = "bonfire_mailer";
              rev = "30448cb3ac78c822cf34ad3695a2779a7b52f5fc";
              hash = "sha256-7cN15K4XZmKnMz8b0RFYpXSD478fuyJwJ+eBUIGquSE=";
            };

            beamDeps = [
              bonfire_common
              gettext
              jason
              swoosh
              mua
              mail
              bamboo
              bamboo_smtp
              bamboo_mailjet
              bamboo_postmark
              bamboo_campaign_monitor
              bamboo_sendcloud
              bamboo_sparkpost
              bamboo_ses
              mjml
              gen_smtp
              faker
              email_checker
            ];
          };
        in
        drv;

      bonfire_me =
        let
          version = "0.1.0";
          drv = buildMix {
            inherit version;
            name = "bonfire_me";
            appConfigPath = ./config;

            src = pkgs.fetchFromGitHub {
              owner = "bonfire-networks";
              repo = "bonfire_me";
              rev = "633705cb1b51e964a110f22867ef6c17fab00cad";
              hash = "sha256-d/0cV96v+2A8n4w2UUlBOavGZ4VmYBovlcGcSC25VEQ=";
            };

            beamDeps = [
              activity_pub
              bonfire_common
              bonfire_epics
              bonfire_mailer
              bonfire_data_activity_pub
              bonfire_data_identity
              bonfire_data_social
              bonfire_boundaries
              needle_ulid
              faker
              telemetry
              telemetry_metrics
              telemetry_poller
              floki
              untangle
              needle
              arrows
              bonfire_data_shared_user
              bonfire_api_graphql
              bonfire_files
              absinthe
              eqrcode
            ];
          };
        in
        drv;

      bonfire_messages =
        let
          version = "0.1.0";
          drv = buildMix {
            inherit version;
            name = "bonfire_messages";
            appConfigPath = ./config;

            src = pkgs.fetchFromGitHub {
              owner = "bonfire-networks";
              repo = "bonfire_messages";
              rev = "892b0542139d2c1b14136056225c973ce27dd223";
              hash = "sha256-XmWt9a2pDTTTe3cj98PpDa5/v9YsiovuX2hOkJRQGps=";
            };

            beamDeps = [
              bonfire_common
              bonfire_posts
              bonfire_epics
              bonfire_ecto
              bonfire_data_social
              verbs
              faker
              exto
              jason
              untangle
              needle
              arrows
              bonfire_me
              bonfire_api_graphql
              absinthe
            ];
          };
        in
        drv;

      bonfire_open_id =
        let
          version = "0.0.1";
          drv = buildMix {
            inherit version;
            name = "bonfire_open_id";
            appConfigPath = ./config;

            src = pkgs.fetchFromGitHub {
              owner = "bonfire-networks";
              repo = "bonfire_open_id";
              rev = "97198a2a0fee32d5749cef801ec80d000806bbee";
              hash = "sha256-Danr8p883Mtqspy+AEqUBG2M6vP4xnQ9BXJgOB4/xcw=";
            };

            beamDeps = [
              bonfire_common
              bonfire_ui_common
              bonfire_me
              boruta
              faker
              jason
              openid_connect
              untangle
              plug_crypto
            ];
          };
        in
        drv;

      bonfire_posts =
        let
          version = "0.1.0";
          drv = buildMix {
            inherit version;
            name = "bonfire_posts";
            appConfigPath = ./config;

            src = pkgs.fetchFromGitHub {
              owner = "bonfire-networks";
              repo = "bonfire_posts";
              rev = "fb96808b36aa1cecf263c78bf4e157ace720c9e0";
              hash = "sha256-kO1w0N53UxCwyPggfOEAfKIYquP7GfxlkffrQqKICZE=";
            };

            beamDeps = [
              bonfire_common
              bonfire_social
              bonfire_epics
              bonfire_ecto
              bonfire_data_social
              verbs
              faker
              exto
              jason
              untangle
              needle
              arrows
              bonfire_me
              bonfire_api_graphql
              absinthe
            ];
          };
        in
        drv;

      bonfire_search =
        let
          version = "0.1.0";
          drv = buildMix {
            inherit version;
            name = "bonfire_search";
            appConfigPath = ./config;

            src = pkgs.fetchFromGitHub {
              owner = "bonfire-networks";
              repo = "bonfire_search";
              rev = "892feec0bf2957d937ef70898f50d3de1513b92d";
              hash = "sha256-bW54UEGoHutie6P/IsY2Qq7nNQkQWaHzbW7tJV9GtaM=";
            };

            beamDeps = [
              bonfire_common
              bonfire_ui_common
              bonfire_epics
              gettext
              jason
              telemetry_metrics
              telemetry_poller
              tesla
              meilisearch_ex
              recase
              fast_ngram
            ];
          };
        in
        drv;

      bonfire_social =
        let
          version = "0.1.0";
          drv = buildMix {
            inherit version;
            name = "bonfire_social";
            appConfigPath = ./config;

            src = pkgs.fetchFromGitHub {
              owner = "bonfire-networks";
              repo = "bonfire_social";
              rev = "3219a53d2ec9eab1a9dd232aa634c20f387cbaa4";
              hash = "sha256-42i7WxoeFUmzgrAZgWVJtVQKxlYMUARkzalRMJ1aVO8=";
            };

            beamDeps = [
              bonfire_common
              bonfire_epics
              bonfire_boundaries
              bonfire_ecto
              bonfire_data_social
              verbs
              nimble_csv
              faker
              exto
              jason
              untangle
              needle
              arrows
              lazy_html
              typed_ecto_schema
              bonfire_me
              bonfire_api_graphql
              bonfire_files
              absinthe
            ];
          };
        in
        drv;

      bonfire_social_graph =
        let
          version = "0.1.0";
          drv = buildMix {
            inherit version;
            name = "bonfire_social_graph";
            appConfigPath = ./config;

            src = pkgs.fetchFromGitHub {
              owner = "bonfire-networks";
              repo = "bonfire_social_graph";
              rev = "6b50e508f32cb9fcc7f498b9b17673b7a191bb03";
              hash = "sha256-+cwxSDTIs6HGkSjtlWdbAz4hv00hfjPr0iFqDNdDemQ=";
            };

            beamDeps = [
              bonfire_common
              bonfire_social
              bonfire_epics
              bonfire_ecto
              bonfire_data_social
              verbs
              nimble_csv
              faker
              exto
              jason
              untangle
              needle
              arrows
              boltx
              bonfire_me
              bonfire_api_graphql
              absinthe
            ];
          };
        in
        drv;

      bonfire_tag =
        let
          version = "0.1.0";
          drv = buildMix {
            inherit version;
            name = "bonfire_tag";
            appConfigPath = ./config;

            src = pkgs.fetchFromGitHub {
              owner = "bonfire-networks";
              repo = "bonfire_tag";
              rev = "0e19805226b357739d785c10ee40f6ee88d738e0";
              hash = "sha256-uyxMrWo6f6Z3Kbb8MO+D5tWNnElA9YLyRgaOw6CFf2Y=";
            };

            beamDeps = [
              bonfire_common
              bonfire_epics
              bonfire_ui_common
              linkify
              faker
              jason
              telemetry_metrics
              telemetry_poller
              html_entities
              untangle
              needle
              arrows
              absinthe
              bonfire_api_graphql
            ];
          };
        in
        drv;

      bonfire_ui_boundaries =
        let
          version = "0.0.1";
          drv = buildMix {
            inherit version;
            name = "bonfire_ui_boundaries";
            appConfigPath = ./config;

            src = pkgs.fetchFromGitHub {
              owner = "bonfire-networks";
              repo = "bonfire_ui_boundaries";
              rev = "6d938adb25a52694f7963eb3bd14af1ed4a8a94e";
              hash = "sha256-1ErZUNjhUOkB1Co6CYOT61W89XoNwbl3riVmEsADfpA=";
            };

            beamDeps = [
              bonfire_common
              bonfire_boundaries
              bonfire_ui_common
              faker
              jason
              untangle
              needle
            ];
          };
        in
        drv;

      bonfire_ui_common =
        let
          version = "0.1.0";
          drv = buildMix {
            inherit version;
            name = "bonfire_ui_common";
            appConfigPath = ./config;

            src = pkgs.fetchFromGitHub {
              owner = "bonfire-networks";
              repo = "bonfire_ui_common";
              rev = "7c8caee21b247734dbd9d2bc1b5e54bde2ae15f2";
              hash = "sha256-/DG+bnZBGtmKe6WvhqvDF2plPksnM3sYvxHs1nt9E8Y=";
            };

            beamDeps = [
              bonfire_common
              phoenix_gon
              bonfire_fail
              iconify_ex
              arrows
              untangle
              jason
              surface
              surface_form_helpers
              phoenix_live_view
              phoenix_live_dashboard
              phoenix_view
              phoenix_ecto
              remote_ip
              plug_cowboy
              faker
              makeup_elixir
              makeup_eex
              makeup_html
              makeup_js
              makeup_json
              makeup_diff
              makeup_sql
              makeup_graphql
              makeup_erlang
              solid
              live_select
              chameleon
              phoenix_live_favicon
              phoenix_seo
              plug_early_hints
              oban
              hammer
              zest
            ];
          };
        in
        drv;

      bonfire_ui_me =
        let
          version = "0.1.0";
          drv = buildMix {
            inherit version;
            name = "bonfire_ui_me";
            appConfigPath = ./config;

            src = pkgs.fetchFromGitHub {
              owner = "bonfire-networks";
              repo = "bonfire_ui_me";
              rev = "d72f314254c3ab93eed4e1eca7372e90db0395ad";
              hash = "sha256-jMSUfzPV9r46rJHdX3gwRSWHkDR+0+dM3reCPB69TUo=";
            };

            beamDeps = [
              bonfire_common
              bonfire_me
              bonfire_ui_common
              bonfire_files
              verbs
              faker
              gettext
              jason
              recase
              telemetry_metrics
              telemetry_poller
              zstream
              floki
              surface
              phoenix_live_view
              phoenix
              untangle
              needle
              arrows
            ];
          };
        in
        drv;

      bonfire_ui_messages =
        let
          version = "0.1.0";
          drv = buildMix {
            inherit version;
            name = "bonfire_ui_messages";
            appConfigPath = ./config;

            src = pkgs.fetchFromGitHub {
              owner = "bonfire-networks";
              repo = "bonfire_ui_messages";
              rev = "6bffd9c36e52f62c92a544911d2c3621be0042a5";
              hash = "sha256-LnabHAgUl/6PpbZqsFNQgLT8YpAAV09CjqeTTxmyvTw=";
            };

            beamDeps = [
              bonfire_common
              bonfire_messages
              bonfire_ui_common
              bonfire_boundaries
              verbs
              faker
              gettext
              jason
              recase
              exdiff
              untangle
              arrows
              bonfire_tag
            ];
          };
        in
        drv;

      bonfire_ui_moderation =
        let
          version = "0.1.0";
          drv = buildMix {
            inherit version;
            name = "bonfire_ui_moderation";
            appConfigPath = ./config;

            src = pkgs.fetchFromGitHub {
              owner = "bonfire-networks";
              repo = "bonfire_ui_moderation";
              rev = "c0f65bfb668f1d650ba7a247f5ae816cc81bc1f3";
              hash = "sha256-p/LMOoBMT77Qx6D20sJMg/ZHPS77hOxYrn1o2z9d6xo=";
            };

            beamDeps = [
              bonfire_common
              bonfire_social
              bonfire_ui_common
              verbs
              faker
              gettext
              jason
              recase
              exdiff
              untangle
              arrows
              bonfire_tag
            ];
          };
        in
        drv;

      bonfire_ui_posts =
        let
          version = "0.1.0";
          drv = buildMix {
            inherit version;
            name = "bonfire_ui_posts";
            appConfigPath = ./config;

            src = pkgs.fetchFromGitHub {
              owner = "bonfire-networks";
              repo = "bonfire_ui_posts";
              rev = "89f6e22315ff9c815e0d9dd408aee5dba5cc2ec6";
              hash = "sha256-6o5ZyCfzexkKZb79xSSwlB2v1G8e+lD+qU7PJd2sKAw=";
            };

            beamDeps = [
              bonfire_common
              bonfire_posts
              bonfire_ui_common
              verbs
              faker
              gettext
              jason
              recase
              exdiff
              untangle
              arrows
              bonfire_tag
            ];
          };
        in
        drv;

      bonfire_ui_reactions =
        let
          version = "0.1.0";
          drv = buildMix {
            inherit version;
            name = "bonfire_ui_reactions";
            appConfigPath = ./config;

            src = pkgs.fetchFromGitHub {
              owner = "bonfire-networks";
              repo = "bonfire_ui_reactions";
              rev = "ae3d27eea98e68c782588ecb5e73c73712d3620b";
              hash = "sha256-PVaUHuSnakOHMnw7eI0DlNskXY9nTkDvjO5Vuotw2Ns=";
            };

            beamDeps = [
              bonfire_common
              bonfire_social
              bonfire_ui_common
              verbs
              faker
              gettext
              jason
              recase
              exdiff
              surface
              untangle
              arrows
              bonfire_tag
            ];
          };
        in
        drv;

      bonfire_ui_social =
        let
          version = "0.1.0";
          drv = buildMix {
            inherit version;
            name = "bonfire_ui_social";
            appConfigPath = ./config;

            src = pkgs.fetchFromGitHub {
              owner = "bonfire-networks";
              repo = "bonfire_ui_social";
              rev = "0bdfcbb3865860c22a9905d3a13a6c050c92d7cd";
              hash = "sha256-3rU5LNP89KmRTpcH9RMZdYtbRKRCibuIz2AudY2AYHo=";
            };

            beamDeps = [
              bonfire_common
              bonfire_social
              bonfire_ui_common
              verbs
              faker
              gettext
              jason
              recase
              exdiff
              surface
              untangle
              arrows
              floki
              bonfire_ui_me
              bonfire_tag
            ];
          };
        in
        drv;

      bonfire_ui_social_graph =
        let
          version = "0.1.0";
          drv = buildMix {
            inherit version;
            name = "bonfire_ui_social_graph";
            appConfigPath = ./config;

            src = pkgs.fetchFromGitHub {
              owner = "bonfire-networks";
              repo = "bonfire_ui_social_graph";
              rev = "14d7c4e1d1c13f6dae53248b3edcb06ea19b9662";
              hash = "sha256-1kSqxB+uC73ShUYFQGJrDojXnR34g+woFrmU7+LotdE=";
            };

            beamDeps = [
              bonfire_common
              bonfire_social_graph
              verbs
              faker
              gettext
              jason
              recase
              exdiff
              untangle
              arrows
              bonfire_tag
            ];
          };
        in
        drv;

      boruta =
        let
          version = "2.3.3";
          drv = buildMix {
            inherit version;
            name = "boruta";
            appConfigPath = ./config;

            src = pkgs.fetchFromGitHub {
              owner = "bonfire-networks";
              repo = "boruta";
              rev = "35191e336f49bc5c52b2e2400c563a92c2732dd5";
              hash = "sha256-FT/ITPvH0J2aleBqm4H9Xp21xzy4TsNlH5C0x0Ctgco=";
            };

            beamDeps = [
              ecto_sql
              ex_json_schema
              finch
              owl
              jason
              joken
              jose
              nebulex
              phoenix
              plug
              postgrex
              puid
              secure_random
              shards
            ];
          };
        in
        drv;

      brex_result =
        let
          version = "0.4.0";
          drv = buildMix {
            inherit version;
            name = "brex_result";
            appConfigPath = ./config;

            src = fetchHex {
              inherit version;
              pkg = "brex_result";
              sha256 = "c221aac71c48727ef55dc56cf845772a54e1db538564280c868eb0595e1e44f8";
            };
          };
        in
        drv;

      cachex =
        let
          version = "4.0.4";
          drv = buildMix {
            inherit version;
            name = "cachex";
            appConfigPath = ./config;

            src = fetchHex {
              inherit version;
              pkg = "cachex";
              sha256 = "a0417593fcca4b6bd0330bb3bbd507c379d5287213ab990dbc0dd704cedede0a";
            };

            beamDeps = [
              eternal
              ex_hash_ring
              jumper
              sleeplocks
              unsafe
            ];
          };
        in
        drv;

      castore =
        let
          version = "1.0.16";
          drv = buildMix {
            inherit version;
            name = "castore";
            appConfigPath = ./config;

            src = fetchHex {
              inherit version;
              pkg = "castore";
              sha256 = "33689203a0eaaf02fcd0e86eadfbcf1bd636100455350592e7e2628564022aaf";
            };
          };
        in
        drv;

      cc_precompiler =
        let
          version = "0.1.11";
          drv = buildMix {
            inherit version;
            name = "cc_precompiler";
            appConfigPath = ./config;

            src = fetchHex {
              inherit version;
              pkg = "cc_precompiler";
              sha256 = "3427232caf0835f94680e5bcf082408a70b48ad68a5f5c0b02a3bea9f3a075b9";
            };

            beamDeps = [
              elixir_make
            ];
          };
        in
        drv.override (workarounds.elixirMake { } drv);

      certifi =
        let
          version = "2.15.0";
          drv = buildRebar3 {
            inherit version;
            name = "certifi";

            src = fetchHex {
              inherit version;
              pkg = "certifi";
              sha256 = "b147ed22ce71d72eafdad94f055165c1c182f61a2ff49df28bcc71d1d5b94a60";
            };
          };
        in
        drv;

      chameleon =
        let
          version = "2.5.0";
          drv = buildMix {
            inherit version;
            name = "chameleon";
            appConfigPath = ./config;

            src = fetchHex {
              inherit version;
              pkg = "chameleon";
              sha256 = "f3559827d8b4fe53a44e19e56ae94bedd36a355e0d33e18067b8abc37ec428db";
            };
          };
        in
        drv;

      chatterbox =
        let
          version = "0.15.1";
          drv = buildRebar3 {
            inherit version;
            name = "chatterbox";

            src = fetchHex {
              inherit version;
              pkg = "ts_chatterbox";
              sha256 = "4f75b91451338bc0da5f52f3480fa6ef6e3a2aeecfc33686d6b3d0a0948f31aa";
            };

            beamDeps = [
              hpack
            ];
          };
        in
        drv;

      cldr_utils =
        let
          version = "2.28.3";
          drv = buildMix {
            inherit version;
            name = "cldr_utils";
            appConfigPath = ./config;

            src = fetchHex {
              inherit version;
              pkg = "cldr_utils";
              sha256 = "40083cd9a5d187f12d675cfeeb39285f0d43e7b7f2143765161b72205d57ffb5";
            };

            beamDeps = [
              castore
              certifi
              decimal
            ];
          };
        in
        drv;

      combine =
        let
          version = "0.10.0";
          drv = buildMix {
            inherit version;
            name = "combine";
            appConfigPath = ./config;

            src = fetchHex {
              inherit version;
              pkg = "combine";
              sha256 = "1b1dbc1790073076580d0d1d64e42eae2366583e7aecd455d1215b0d16f2451b";
            };
          };
        in
        drv;

      comeonin =
        let
          version = "5.5.1";
          drv = buildMix {
            inherit version;
            name = "comeonin";
            appConfigPath = ./config;

            src = fetchHex {
              inherit version;
              pkg = "comeonin";
              sha256 = "65aac8f19938145377cee73973f192c5645873dcf550a8a6b18187d17c13ccdb";
            };
          };
        in
        drv;

      complex =
        let
          version = "0.6.0";
          drv = buildMix {
            inherit version;
            name = "complex";
            appConfigPath = ./config;

            src = fetchHex {
              inherit version;
              pkg = "complex";
              sha256 = "0a5fa95580dcaf30fcd60fe1aaf24327c0fe401e98c24d892e172e79498269f9";
            };
          };
        in
        drv;

      corsica =
        let
          version = "2.1.3";
          drv = buildMix {
            inherit version;
            name = "corsica";
            appConfigPath = ./config;

            src = fetchHex {
              inherit version;
              pkg = "corsica";
              sha256 = "616c08f61a345780c2cf662ff226816f04d8868e12054e68963e95285b5be8bc";
            };

            beamDeps = [
              plug
              telemetry
            ];
          };
        in
        drv;

      cowboy =
        let
          version = "2.14.2";
          drv = buildRebar3 {
            inherit version;
            name = "cowboy";

            src = fetchHex {
              inherit version;
              pkg = "cowboy";
              sha256 = "569081da046e7b41b5df36aa359be71a0c8874e5b9cff6f747073fc57baf1ab9";
            };

            beamDeps = [
              cowlib
              ranch
            ];
          };
        in
        drv;

      cowboy_telemetry =
        let
          version = "0.4.0";
          drv = buildRebar3 {
            inherit version;
            name = "cowboy_telemetry";

            src = fetchHex {
              inherit version;
              pkg = "cowboy_telemetry";
              sha256 = "7d98bac1ee4565d31b62d59f8823dfd8356a169e7fcbb83831b8a5397404c9de";
            };

            beamDeps = [
              cowboy
              telemetry
            ];
          };
        in
        drv;

      cowlib =
        let
          version = "2.16.0";
          drv = buildRebar3 {
            inherit version;
            name = "cowlib";

            src = fetchHex {
              inherit version;
              pkg = "cowlib";
              sha256 = "7f478d80d66b747344f0ea7708c187645cfcc08b11aa424632f78e25bf05db51";
            };
          };
        in
        drv;

      crypto_rand =
        let
          version = "1.0.4";
          drv = buildMix {
            inherit version;
            name = "crypto_rand";
            appConfigPath = ./config;

            src = fetchHex {
              inherit version;
              pkg = "crypto_rand";
              sha256 = "ad1862fd3e1c938f60982902632474868ea96901d75dd53f0ec32dd55e123549";
            };
          };
        in
        drv;

      ctx =
        let
          version = "0.6.0";
          drv = buildRebar3 {
            inherit version;
            name = "ctx";

            src = fetchHex {
              inherit version;
              pkg = "ctx";
              sha256 = "a14ed2d1b67723dbebbe423b28d7615eb0bdcba6ff28f2d1f1b0a7e1d4aa5fc2";
            };
          };
        in
        drv;

      dataloader =
        let
          version = "2.0.2";
          drv = buildMix {
            inherit version;
            name = "dataloader";
            appConfigPath = ./config;

            src = fetchHex {
              inherit version;
              pkg = "dataloader";
              sha256 = "4c6cabc0b55e96e7de74d14bf37f4a5786f0ab69aa06764a1f39dda40079b098";
            };

            beamDeps = [
              ecto
              opentelemetry_process_propagator
              telemetry
            ];
          };
        in
        drv;

      db_connection =
        let
          version = "2.8.1";
          drv = buildMix {
            inherit version;
            name = "db_connection";
            appConfigPath = ./config;

            src = fetchHex {
              inherit version;
              pkg = "db_connection";
              sha256 = "a61a3d489b239d76f326e03b98794fb8e45168396c925ef25feb405ed09da8fd";
            };

            beamDeps = [
              telemetry
            ];
          };
        in
        drv;

      decimal =
        let
          version = "2.3.0";
          drv = buildMix {
            inherit version;
            name = "decimal";
            appConfigPath = ./config;

            src = fetchHex {
              inherit version;
              pkg = "decimal";
              sha256 = "a4d66355cb29cb47c3cf30e71329e58361cfcb37c34235ef3bf1d7bf3773aeac";
            };
          };
        in
        drv;

      decorator =
        let
          version = "1.4.0";
          drv = buildMix {
            inherit version;
            name = "decorator";
            appConfigPath = ./config;

            src = fetchHex {
              inherit version;
              pkg = "decorator";
              sha256 = "0a07cedd9083da875c7418dea95b78361197cf2bf3211d743f6f7ce39656597f";
            };
          };
        in
        drv;

      deep_merge =
        let
          version = "1.0.0";
          drv = buildMix {
            inherit version;
            name = "deep_merge";
            appConfigPath = ./config;

            src = fetchHex {
              inherit version;
              pkg = "deep_merge";
              sha256 = "ce708e5f094b9cd4e8f2be4f00d2f4250c4095be93f8cd6d018c753894885430";
            };
          };
        in
        drv;

      deps_nix =
        let
          version = "2.6.0";
          drv = buildMix {
            inherit version;
            name = "deps_nix";
            appConfigPath = ./config;

            src = pkgs.fetchFromGitHub {
              owner = "code-supply";
              repo = "deps_nix";
              rev = "509ab43c0bc4276aeefab13a184dd75eb18ef9ac";
              hash = "sha256-Rmb0e0n4TP8JWggp2HO0VIuESSP+gIs0v4RQH8dI0h4=";
            };

            beamDeps = [
              ex_nar
              mint
            ];
          };
        in
        drv;

      digital_token =
        let
          version = "1.0.0";
          drv = buildMix {
            inherit version;
            name = "digital_token";
            appConfigPath = ./config;

            src = fetchHex {
              inherit version;
              pkg = "digital_token";
              sha256 = "8ed6f5a8c2fa7b07147b9963db506a1b4c7475d9afca6492136535b064c9e9e6";
            };

            beamDeps = [
              cldr_utils
              jason
            ];
          };
        in
        drv;

      dog_sketch =
        let
          version = "0.1.3";
          drv = buildMix {
            inherit version;
            name = "dog_sketch";
            appConfigPath = ./config;

            src = fetchHex {
              inherit version;
              pkg = "dog_sketch";
              sha256 = "be6d172a3d3809a0acbc85421a5d25a794841560b6f930540c345342c591d0df";
            };
          };
        in
        drv;

      earmark_parser =
        let
          version = "1.4.44";
          drv = buildMix {
            inherit version;
            name = "earmark_parser";
            appConfigPath = ./config;

            src = fetchHex {
              inherit version;
              pkg = "earmark_parser";
              sha256 = "4778ac752b4701a5599215f7030989c989ffdc4f6df457c5f36938cc2d2a2750";
            };
          };
        in
        drv;

      ecto =
        let
          version = "3.13.5";
          drv = buildMix {
            inherit version;
            name = "ecto";
            appConfigPath = ./config;

            src = fetchHex {
              inherit version;
              pkg = "ecto";
              sha256 = "df9efebf70cf94142739ba357499661ef5dbb559ef902b68ea1f3c1fabce36de";
            };

            beamDeps = [
              decimal
              jason
              telemetry
            ];
          };
        in
        drv;

      ecto_dev_logger =
        let
          version = "0.14.1";
          drv = buildMix {
            inherit version;
            name = "ecto_dev_logger";
            appConfigPath = ./config;

            src = fetchHex {
              inherit version;
              pkg = "ecto_dev_logger";
              sha256 = "14a64ebae728b3c45db6ba8bb185979c8e01fc1b0d3d1d9c01c7a2b798e8c698";
            };

            beamDeps = [
              ecto
              geo
              jason
            ];
          };
        in
        drv;

      ecto_materialized_path =
        let
          version = "0.3.0";
          drv = buildMix {
            inherit version;
            name = "ecto_materialized_path";
            appConfigPath = ./config;

            src = pkgs.fetchFromGitHub {
              owner = "bonfire-networks";
              repo = "ecto_materialized_path";
              rev = "5400b058d7ddd24379db3662c29b51d0cec82756";
              hash = "sha256-RSvgcL7X5Gvlej5axsl8WLltGHzaMcRfdiEPUlufcas=";
            };

            beamDeps = [
              ecto
              needle_uid
              untangle
            ];
          };
        in
        drv;

      ecto_psql_extras =
        let
          version = "0.8.8";
          drv = buildMix {
            inherit version;
            name = "ecto_psql_extras";
            appConfigPath = ./config;

            src = fetchHex {
              inherit version;
              pkg = "ecto_psql_extras";
              sha256 = "04c63d92b141723ad6fed2e60a4b461ca00b3594d16df47bbc48f1f4534f2c49";
            };

            beamDeps = [
              ecto_sql
              postgrex
              table_rex
            ];
          };
        in
        drv;

      ecto_ranked =
        let
          version = "0.6.1";
          drv = buildMix {
            inherit version;
            name = "ecto_ranked";
            appConfigPath = ./config;

            src = fetchHex {
              inherit version;
              pkg = "ecto_ranked";
              sha256 = "39504f290103950448926637660cb91f02b936e75bb6ae307cbcf80bf487962d";
            };

            beamDeps = [
              ecto_sql
            ];
          };
        in
        drv;

      ecto_shorts =
        let
          version = "1.1.1";
          drv = buildMix {
            inherit version;
            name = "ecto_shorts";
            appConfigPath = ./config;

            src = pkgs.fetchFromGitHub {
              owner = "bonfire-networks";
              repo = "ecto_shorts";
              rev = "34ac78036b249aec833ae357f69195e46306f817";
              hash = "sha256-4OxxcNE5N5xn9OcO3GiA0hitnyLnej5lupfsRZ2It/0=";
            };

            beamDeps = [
              ecto_sql
            ];
          };
        in
        drv;

      ecto_sparkles =
        let
          version = "0.2.1";
          drv = buildMix {
            inherit version;
            name = "ecto_sparkles";
            appConfigPath = ./config;

            src = pkgs.fetchFromGitHub {
              owner = "bonfire-networks";
              repo = "ecto_sparkles";
              rev = "542fa562aa6d03689ea4119896f5c20224dcd724";
              hash = "sha256-ETKbMd6y8Wa1XZq1EPDktN6rtMie/PKUIJKchxGNLmk=";
            };

            beamDeps = [
              ecto
              ecto_sql
              ecto_dev_logger
              recase
              untangle
              json_serde
              html_sanitize_ex
            ];
          };
        in
        drv;

      ecto_sql =
        let
          version = "3.13.2";
          drv = buildMix {
            inherit version;
            name = "ecto_sql";
            appConfigPath = ./config;

            src = fetchHex {
              inherit version;
              pkg = "ecto_sql";
              sha256 = "539274ab0ecf1a0078a6a72ef3465629e4d6018a3028095dc90f60a19c371717";
            };

            beamDeps = [
              db_connection
              ecto
              postgrex
              telemetry
            ];
          };
        in
        drv;

      ecto_vista =
        let
          version = "0.2.0";
          drv = buildMix {
            inherit version;
            name = "ecto_vista";
            appConfigPath = ./config;

            src = fetchHex {
              inherit version;
              pkg = "ecto_vista";
              sha256 = "a1beb25e78e418b6437ed1d2e3f299b1822390926e58a02954be9c4718377a12";
            };

            beamDeps = [
              ecto
              ecto_sql
              postgrex
            ];
          };
        in
        drv;

      elbat =
        let
          version = "0.0.6";
          drv = buildMix {
            inherit version;
            name = "elbat";
            appConfigPath = ./config;

            src = fetchHex {
              inherit version;
              pkg = "elbat";
              sha256 = "74bbac013afe869123833273e5f26826fad453e17c09aeabcb7d8d0a74baf868";
            };
          };
        in
        drv;

      elixir_make =
        let
          version = "0.9.0";
          drv = buildMix {
            inherit version;
            name = "elixir_make";
            appConfigPath = ./config;

            src = fetchHex {
              inherit version;
              pkg = "elixir_make";
              sha256 = "db23d4fd8b757462ad02f8aa73431a426fe6671c80b200d9710caf3d1dd0ffdb";
            };
          };
        in
        drv;

      email_checker =
        let
          version = "0.2.4";
          drv = buildMix {
            inherit version;
            name = "email_checker";
            appConfigPath = ./config;

            src = fetchHex {
              inherit version;
              pkg = "email_checker";
              sha256 = "e4ac0e5eb035dce9c8df08ebffdb525a5d82e61dde37390ac2469222f723e50a";
            };
          };
        in
        drv;

      ember =
        let
          version = "0.0.1";
          drv = buildMix {
            inherit version;
            name = "ember";
            appConfigPath = ./config;

            src = pkgs.fetchFromGitHub {
              owner = "bonfire-networks";
              repo = "ember";
              rev = "906eb95a9cca3e22d5393b44a40fce21145231d6";
              hash = "sha256-v6+YrIClyG0Cfhk9ude7mYxs52mtWZ/ZKuVob9pl6Mk=";
            };

            beamDeps = [
              bonfire_common
              bonfire_ui_common
              activity_pub
              bonfire_mailer
              bonfire_epics
              bonfire_ecto
              bonfire_data_assort
              bonfire_boundaries
              bonfire_ui_boundaries
              bonfire_federate_activitypub
              bonfire_data_access_control
              bonfire_data_activity_pub
              bonfire_data_identity
              bonfire_data_social
              bonfire_data_edges
              bonfire_editor_milkdown
              bonfire_me
              bonfire_ui_me
              bonfire_social
              bonfire_social_graph
              bonfire_posts
              bonfire_ui_social
              bonfire_ui_social_graph
              bonfire_ui_posts
              bonfire_ui_moderation
              bonfire_tag
              bonfire_classify
              ecto_sparkles
              needle
              needle_uid
              needle_ulid
              ex_ulid
              untangle
              entrepot
              entrepot_ecto
              nodeinfo
              paginator
              voodoo
              arrows
              surface
              phoenix
              phoenix_live_view
              phoenix_view
              plug_crypto
              plug_cowboy
              cowboy
              bandit
              orion
              corsica
              ecto
              ecto_sql
              exto
              postgrex
              ecto_psql_extras
              db_connection
              ex_aws_s3
              ex_marcel
              req
              finch
              httpoison
              jason
              poison
              timex
              solid
              mime
              oban
              sourceror
              owl
              mogrify
              cachex
              sizeable
              geo
              recase
              emote
              uniq
              rustler_precompiled
              decimal
              floki
              faker
              gettext
              text
              text_corpus_udhr
              hackney
              opentelemetry_process_propagator
              opentelemetry_exporter
              opentelemetry_semantic_conventions
              telemetry_metrics
              telemetry
              telemetry_poller
              sentry
              oban_web
              absinthe
              bonfire_api_graphql
              absinthe_client
            ];
          };
        in
        drv.override (workarounds.rustlerPrecompiled { } drv);

      emote =
        let
          version = "0.1.1";
          drv = buildMix {
            inherit version;
            name = "emote";
            appConfigPath = ./config;

            src = fetchHex {
              inherit version;
              pkg = "emote";
              sha256 = "d11219eb76966b0f38adb5ad12eef8dc6c7bb3929cfcdcd4ce9deb2bf784a0ce";
            };

            beamDeps = [
              phoenix_html
            ];
          };
        in
        drv;

      entrepot =
        let
          version = "0.11.0";
          drv = buildMix {
            inherit version;
            name = "entrepot";
            appConfigPath = ./config;

            src = pkgs.fetchFromGitHub {
              owner = "bonfire-networks";
              repo = "entrepot";
              rev = "c75704d8b4b76dbd2277b52822fa77ec8dc207aa";
              hash = "sha256-sFLvmdAThsdTpVs+ThhwxR7zuZgMbye+pQSE2Y+80do=";
            };

            beamDeps = [
              ex_aws
              ex_aws_s3
            ];
          };
        in
        drv;

      entrepot_ecto =
        let
          version = "0.11.0";
          drv = buildMix {
            inherit version;
            name = "entrepot_ecto";
            appConfigPath = ./config;

            src = pkgs.fetchFromGitHub {
              owner = "bonfire-networks";
              repo = "entrepot_ecto";
              rev = "5ea4af9af6b648e2cf58a2ceb2eb8e9c36c2b226";
              hash = "sha256-yOdb7S7FwOaslvxR4b2naxlOnYGMx0CI7jf5DmPHaUw=";
            };

            beamDeps = [
              entrepot
              ecto
            ];
          };
        in
        drv;

      eqrcode =
        let
          version = "0.2.1";
          drv = buildMix {
            inherit version;
            name = "eqrcode";
            appConfigPath = ./config;

            src = fetchHex {
              inherit version;
              pkg = "eqrcode";
              sha256 = "d5828a222b904c68360e7dc2a40c3ef33a1328b7c074583898040f389f928025";
            };
          };
        in
        drv;

      eternal =
        let
          version = "1.2.2";
          drv = buildMix {
            inherit version;
            name = "eternal";
            appConfigPath = ./config;

            src = fetchHex {
              inherit version;
              pkg = "eternal";
              sha256 = "2c9fe32b9c3726703ba5e1d43a1d255a4f3f2d8f8f9bc19f094c7cb1a7a9e782";
            };
          };
        in
        drv;

      evision =
        let
          version = "0.2.14";
          drv = buildMix {
            inherit version;
            name = "evision";
            appConfigPath = ./config;

            src = fetchHex {
              inherit version;
              pkg = "evision";
              sha256 = "630714395f2c242e488944b4c9c75a5de96cbb95d3cbb69f0525bdb3e0a88775";
            };

            beamDeps = [
              castore
              elixir_make
              nx
            ];
          };
        in
        drv.override (workarounds.elixirMake { } drv);

      ex2ms =
        let
          version = "1.7.0";
          drv = buildMix {
            inherit version;
            name = "ex2ms";
            appConfigPath = ./config;

            src = fetchHex {
              inherit version;
              pkg = "ex2ms";
              sha256 = "2589eee51f81f1b1caa6d08c990b1ad409215fe6f64c73f73c67d36ed10be827";
            };
          };
        in
        drv;

      ex_aws =
        let
          version = "2.5.11";
          drv = buildMix {
            inherit version;
            name = "ex_aws";
            appConfigPath = ./config;

            src = fetchHex {
              inherit version;
              pkg = "ex_aws";
              sha256 = "7e16100ff93a118ef01c916d945969535cbe8d4ab6593fcf01d1cf854eb75345";
            };

            beamDeps = [
              hackney
              jason
              mime
              req
              sweet_xml
              telemetry
            ];
          };
        in
        drv;

      ex_aws_s3 =
        let
          version = "2.5.8";
          drv = buildMix {
            inherit version;
            name = "ex_aws_s3";
            appConfigPath = ./config;

            src = fetchHex {
              inherit version;
              pkg = "ex_aws_s3";
              sha256 = "84e512ca2e0ae6a6c497036dff06d4493ffb422cfe476acc811d7c337c16691c";
            };

            beamDeps = [
              ex_aws
              sweet_xml
            ];
          };
        in
        drv;

      ex_aws_sts =
        let
          version = "2.3.0";
          drv = buildMix {
            inherit version;
            name = "ex_aws_sts";
            appConfigPath = ./config;

            src = fetchHex {
              inherit version;
              pkg = "ex_aws_sts";
              sha256 = "f14e4c7da3454514bf253b331e9422d25825485c211896ab3b81d2a4bdbf62f5";
            };

            beamDeps = [
              ex_aws
            ];
          };
        in
        drv;

      ex_cldr =
        let
          version = "2.43.2";
          drv = buildMix {
            inherit version;
            name = "ex_cldr";
            appConfigPath = ./config;

            src = fetchHex {
              inherit version;
              pkg = "ex_cldr";
              sha256 = "095137a7bd081166f77d23291b0649db2136ca013245cb73955fb0515031272a";
            };

            beamDeps = [
              cldr_utils
              decimal
              gettext
              jason
              nimble_parsec
            ];
          };
        in
        drv;

      ex_cldr_calendars =
        let
          version = "2.3.1";
          drv = buildMix {
            inherit version;
            name = "ex_cldr_calendars";
            appConfigPath = ./config;

            src = fetchHex {
              inherit version;
              pkg = "ex_cldr_calendars";
              sha256 = "42d24fe2ff5316b4d2425f14aeae320886dccdf42060493d6ddfa05f518caf53";
            };

            beamDeps = [
              ex_cldr_lists
              ex_cldr_numbers
              ex_cldr_units
              ex_doc
              jason
            ];
          };
        in
        drv;

      ex_cldr_currencies =
        let
          version = "2.16.5";
          drv = buildMix {
            inherit version;
            name = "ex_cldr_currencies";
            appConfigPath = ./config;

            src = fetchHex {
              inherit version;
              pkg = "ex_cldr_currencies";
              sha256 = "4397179028f0a7389de278afd0239771f39ba8d1984ce072bc9b715fa28f30d3";
            };

            beamDeps = [
              ex_cldr
              jason
            ];
          };
        in
        drv;

      ex_cldr_dates_times =
        let
          version = "2.24.0";
          drv = buildMix {
            inherit version;
            name = "ex_cldr_dates_times";
            appConfigPath = ./config;

            src = fetchHex {
              inherit version;
              pkg = "ex_cldr_dates_times";
              sha256 = "d30ef69a4953dc987a2055c040122507695490ba7d8b88e16e28a27e40e6ff03";
            };

            beamDeps = [
              ex_cldr
              ex_cldr_calendars
              ex_cldr_numbers
              ex_cldr_units
              jason
            ];
          };
        in
        drv;

      ex_cldr_languages =
        let
          version = "0.3.3";
          drv = buildMix {
            inherit version;
            name = "ex_cldr_languages";
            appConfigPath = ./config;

            src = fetchHex {
              inherit version;
              pkg = "ex_cldr_languages";
              sha256 = "22fb1fef72b7b4b4872d243b34e7b83734247a78ad87377986bf719089cc447a";
            };

            beamDeps = [
              ex_cldr
              jason
            ];
          };
        in
        drv;

      ex_cldr_lists =
        let
          version = "2.11.1";
          drv = buildMix {
            inherit version;
            name = "ex_cldr_lists";
            appConfigPath = ./config;

            src = fetchHex {
              inherit version;
              pkg = "ex_cldr_lists";
              sha256 = "00161c04510ccb3f18b19a6b8562e50c21f1e9c15b8ff4c934bea5aad0b4ade2";
            };

            beamDeps = [
              ex_cldr_numbers
              ex_doc
              jason
            ];
          };
        in
        drv;

      ex_cldr_locale_display =
        let
          version = "1.6.1";
          drv = buildMix {
            inherit version;
            name = "ex_cldr_locale_display";
            appConfigPath = ./config;

            src = fetchHex {
              inherit version;
              pkg = "ex_cldr_locale_display";
              sha256 = "d626c3270bc34a0792fb963777db0fa0bbf5d920767f4a6944cc8b0cc4107016";
            };

            beamDeps = [
              ex_cldr
              ex_cldr_currencies
              ex_cldr_territories
              jason
            ];
          };
        in
        drv;

      ex_cldr_numbers =
        let
          version = "2.35.2";
          drv = buildMix {
            inherit version;
            name = "ex_cldr_numbers";
            appConfigPath = ./config;

            src = fetchHex {
              inherit version;
              pkg = "ex_cldr_numbers";
              sha256 = "6db5fc81a7de7efe9e9bd66fb2f436b5f82cdbf88deea38f513e8432533856dd";
            };

            beamDeps = [
              decimal
              digital_token
              ex_cldr
              ex_cldr_currencies
              jason
            ];
          };
        in
        drv;

      ex_cldr_plugs =
        let
          version = "1.3.3";
          drv = buildMix {
            inherit version;
            name = "ex_cldr_plugs";
            appConfigPath = ./config;

            src = fetchHex {
              inherit version;
              pkg = "ex_cldr_plugs";
              sha256 = "23ebfa8d7a9991b71515c865ddf00099c9a23425767fb5dcbbca636df4aaeaab";
            };

            beamDeps = [
              ex_cldr
              gettext
              jason
              plug
            ];
          };
        in
        drv;

      ex_cldr_territories =
        let
          version = "2.10.0";
          drv = buildMix {
            inherit version;
            name = "ex_cldr_territories";
            appConfigPath = ./config;

            src = fetchHex {
              inherit version;
              pkg = "ex_cldr_territories";
              sha256 = "13f084f9283f8ab1ba5bf3aead936f008341297a8291be6236efaffd1a200e95";
            };

            beamDeps = [
              ex_cldr
              jason
            ];
          };
        in
        drv;

      ex_cldr_units =
        let
          version = "3.19.1";
          drv = buildMix {
            inherit version;
            name = "ex_cldr_units";
            appConfigPath = ./config;

            src = fetchHex {
              inherit version;
              pkg = "ex_cldr_units";
              sha256 = "63023b6e5c1ec159d9e50f50c2d271127a1263a2316dff5a08b7b4a0f82bf1f8";
            };

            beamDeps = [
              cldr_utils
              decimal
              ex_cldr_lists
              ex_cldr_numbers
              ex_doc
              jason
            ];
          };
        in
        drv;

      ex_doc =
        let
          version = "0.38.4";
          drv = buildMix {
            inherit version;
            name = "ex_doc";
            appConfigPath = ./config;

            src = fetchHex {
              inherit version;
              pkg = "ex_doc";
              sha256 = "f7b62346408a83911c2580154e35613eb314e0278aeea72ed7fedef9c1f165b2";
            };

            beamDeps = [
              earmark_parser
              makeup_elixir
              makeup_erlang
              makeup_html
            ];
          };
        in
        drv;

      ex_hash_ring =
        let
          version = "6.0.4";
          drv = buildMix {
            inherit version;
            name = "ex_hash_ring";
            appConfigPath = ./config;

            src = fetchHex {
              inherit version;
              pkg = "ex_hash_ring";
              sha256 = "89adabf31f7d3dfaa36802ce598ce918e9b5b33bae8909ac1a4d052e1e567d18";
            };
          };
        in
        drv;

      ex_json_schema =
        let
          version = "0.11.1";
          drv = buildMix {
            inherit version;
            name = "ex_json_schema";
            appConfigPath = ./config;

            src = fetchHex {
              inherit version;
              pkg = "ex_json_schema";
              sha256 = "32d651a575a6ce2fd613f140b0fef8dd0acc7cf8e8bcd29a3a1be5c945700dd5";
            };

            beamDeps = [
              decimal
            ];
          };
        in
        drv;

      ex_marcel =
        let
          version = "0.1.0";
          drv = buildMix {
            inherit version;
            name = "ex_marcel";
            appConfigPath = ./config;

            src = fetchHex {
              inherit version;
              pkg = "ex_marcel";
              sha256 = "48dfc497435a9c52c0e90c1e07d8ce7316a095dcec0e04d182e8250e493b72fb";
            };
          };
        in
        drv;

      ex_nar =
        let
          version = "0.3.0";
          drv = buildMix {
            inherit version;
            name = "ex_nar";
            appConfigPath = ./config;

            src = fetchHex {
              inherit version;
              pkg = "ex_nar";
              sha256 = "cbb42d047764feac6c411efddcadc31866e9a998dd6e2bc1eb428cec1c49fdcd";
            };
          };
        in
        drv;

      ex_ulid =
        let
          version = "0.1.0";
          drv = buildMix {
            inherit version;
            name = "ex_ulid";
            appConfigPath = ./config;

            src = pkgs.fetchFromGitHub {
              owner = "bonfire-networks";
              repo = "ex_ulid";
              rev = "b07e0410b9d683385de081cfd5af0e3225b270f9";
              hash = "sha256-9G6o63auGDcrKGFRc0DLROLbBu3CiwKPlJ7Pt7vF8Hg=";
            };
          };
        in
        drv;

      exdiff =
        let
          version = "0.1.5";
          drv = buildMix {
            inherit version;
            name = "exdiff";
            appConfigPath = ./config;

            src = fetchHex {
              inherit version;
              pkg = "exdiff";
              sha256 = "b1ccef642edc28ed3acf1b08c8dbc6e42852d18dfe51b453529588e53c733eba";
            };
          };
        in
        drv;

      exkismet =
        let
          version = "0.0.3";
          drv = buildMix {
            inherit version;
            name = "exkismet";
            appConfigPath = ./config;

            src = pkgs.fetchFromGitHub {
              owner = "tcitworld";
              repo = "exkismet";
              rev = "68830454608d315f69d5fe1061ac1bf31c1a856e";
              hash = "sha256-mwLRQjAZoZSRLIQ7Xzp5SgSXu4JRXmgtgUcN+EteSsU=";
            };

            beamDeps = [
              httpoison
            ];
          };
        in
        drv;

      expo =
        let
          version = "1.1.0";
          drv = buildMix {
            inherit version;
            name = "expo";
            appConfigPath = ./config;

            src = fetchHex {
              inherit version;
              pkg = "expo";
              sha256 = "fbadf93f4700fb44c331362177bdca9eeb8097e8b0ef525c9cc501cb9917c960";
            };
          };
        in
        drv;

      exto =
        let
          version = "0.4.0";
          drv = buildMix {
            inherit version;
            name = "exto";
            appConfigPath = ./config;

            src = fetchHex {
              inherit version;
              pkg = "exto";
              sha256 = "447afd96c2190c861db9f6201dfb733175473347a23c0c9d3169e17686ec7fd6";
            };

            beamDeps = [
              accessible
              ecto
            ];
          };
        in
        drv;

      faker =
        let
          version = "0.19.0-alpha.1";
          drv = buildMix {
            inherit version;
            name = "faker";
            appConfigPath = ./config;

            src = fetchHex {
              inherit version;
              pkg = "faker";
              sha256 = "b89d00c26712d473c6a0e2105da4dc2e3cdba14642e898a103d7271717daf0bb";
            };

            beamDeps = [
              makeup
              makeup_elixir
            ];
          };
        in
        drv;

      fast_ngram =
        let
          version = "1.2.0";
          drv = buildMix {
            inherit version;
            name = "fast_ngram";
            appConfigPath = ./config;

            src = fetchHex {
              inherit version;
              pkg = "fast_ngram";
              sha256 = "90c949c5b00314d8117a5bf2fbf6a05ef945ce4cad66a47bc26f8d9ec30dc1bd";
            };
          };
        in
        drv;

      faviconic =
        let
          version = "0.2.1";
          drv = buildMix {
            inherit version;
            name = "faviconic";
            appConfigPath = ./config;

            src = fetchHex {
              inherit version;
              pkg = "faviconic";
              sha256 = "24f3628abd9b55d75e4f90edf6e8dfb97d0baf834345d40342232622d2094655";
            };

            beamDeps = [
              floki
              req
              untangle
            ];
          };
        in
        drv;

      file_info =
        let
          version = "0.0.4";
          drv = buildMix {
            inherit version;
            name = "file_info";
            appConfigPath = ./config;

            src = fetchHex {
              inherit version;
              pkg = "file_info";
              sha256 = "50e7ad01c2c8b9339010675fe4dc4a113b8d6ca7eddce24d1d74fd0e762781a5";
            };

            beamDeps = [
              mimetype_parser
            ];
          };
        in
        drv;

      file_system =
        let
          version = "1.1.1";
          drv = buildMix {
            inherit version;
            name = "file_system";
            appConfigPath = ./config;

            src = fetchHex {
              inherit version;
              pkg = "file_system";
              sha256 = "7a15ff97dfe526aeefb090a7a9d3d03aa907e100e262a0f8f7746b78f8f87a5d";
            };
          };
        in
        drv;

      finch =
        let
          version = "0.20.0";
          drv = buildMix {
            inherit version;
            name = "finch";
            appConfigPath = ./config;

            src = fetchHex {
              inherit version;
              pkg = "finch";
              sha256 = "2658131a74d051aabfcba936093c903b8e89da9a1b63e430bee62045fa9b2ee2";
            };

            beamDeps = [
              mime
              mint
              nimble_options
              nimble_pool
              telemetry
            ];
          };
        in
        drv;

      fine =
        let
          version = "0.1.4";
          drv = buildMix {
            inherit version;
            name = "fine";
            appConfigPath = ./config;

            src = fetchHex {
              inherit version;
              pkg = "fine";
              sha256 = "be3324cc454a42d80951cf6023b9954e9ff27c6daa255483b3e8d608670303f5";
            };
          };
        in
        drv;

      floki =
        let
          version = "0.37.1";
          drv = buildMix {
            inherit version;
            name = "floki";
            appConfigPath = ./config;

            src = fetchHex {
              inherit version;
              pkg = "floki";
              sha256 = "673d040cb594d31318d514590246b6dd587ed341d3b67e17c1c0eb8ce7ca6f04";
            };
          };
        in
        drv;

      flow =
        let
          version = "0.15.0";
          drv = buildMix {
            inherit version;
            name = "flow";
            appConfigPath = ./config;

            src = fetchHex {
              inherit version;
              pkg = "flow";
              sha256 = "d7ecbd4dd38a188494bc996d5014ef8335f436a0b262140a1f6441ae94714581";
            };

            beamDeps = [
              gen_stage
            ];
          };
        in
        drv;

      forecastr =
        let
          version = "0.3.0";
          drv = buildMix {
            inherit version;
            name = "forecastr";
            appConfigPath = ./config;

            src = pkgs.fetchFromGitHub {
              owner = "bonfire-networks";
              repo = "forecastr";
              rev = "96b97b3acac6b7b9185bcca9e1b69cf9256673ca";
              hash = "sha256-miMkI2DXBcAFtVsAGXTybuxUypuZE+ZD2vOHiJw+4qw=";
            };

            beamDeps = [
              httpoison
              jason
              elbat
              mogrify
            ];
          };
        in
        drv;

      gen_smtp =
        let
          version = "1.3.0";
          drv = buildRebar3 {
            inherit version;
            name = "gen_smtp";

            src = fetchHex {
              inherit version;
              pkg = "gen_smtp";
              sha256 = "0b73fbf069864ecbce02fe653b16d3f35fd889d0fdd4e14527675565c39d84e6";
            };

            beamDeps = [
              ranch
            ];
          };
        in
        drv;

      gen_stage =
        let
          version = "0.14.3";
          drv = buildMix {
            inherit version;
            name = "gen_stage";
            appConfigPath = ./config;

            src = fetchHex {
              inherit version;
              pkg = "gen_stage";
              sha256 = "8453e2289d94c3199396eb517d65d6715ef26bcae0ee83eb5ff7a84445458d76";
            };
          };
        in
        drv;

      geo =
        let
          version = "4.1.0";
          drv = buildMix {
            inherit version;
            name = "geo";
            appConfigPath = ./config;

            src = fetchHex {
              inherit version;
              pkg = "geo";
              sha256 = "19edb2b3398ca9f701b573b1fb11bc90951ebd64f18b06bd1bf35abe509a2934";
            };

            beamDeps = [
              jason
            ];
          };
        in
        drv;

      geo_postgis =
        let
          version = "3.7.1";
          drv = buildMix {
            inherit version;
            name = "geo_postgis";
            appConfigPath = ./config;

            src = fetchHex {
              inherit version;
              pkg = "geo_postgis";
              sha256 = "c20d823c600d35b7fe9ddd5be03052bb7136c57d6f1775dbd46871545e405280";
            };

            beamDeps = [
              ecto
              geo
              jason
              poison
              postgrex
            ];
          };
        in
        drv;

      geocoder =
        let
          version = "2.2.2";
          drv = buildMix {
            inherit version;
            name = "geocoder";
            appConfigPath = ./config;

            src = fetchHex {
              inherit version;
              pkg = "geocoder";
              sha256 = "e01404586f246d95fd6affcac86b8454a442ac2d6774bf47ac67e6c79d5b9cb5";
            };

            beamDeps = [
              geohash
              httpoison
              jason
              poolboy
              towel
            ];
          };
        in
        drv;

      geohash =
        let
          version = "1.3.0";
          drv = buildMix {
            inherit version;
            name = "geohash";
            appConfigPath = ./config;

            src = fetchHex {
              inherit version;
              pkg = "geohash";
              sha256 = "50a378ccf19fe5147ffa586ea2aa3608566bcefb5a8804ffb6eab7d4f7871403";
            };
          };
        in
        drv;

      gettext =
        let
          version = "0.26.2";
          drv = buildMix {
            inherit version;
            name = "gettext";
            appConfigPath = ./config;

            src = fetchHex {
              inherit version;
              pkg = "gettext";
              sha256 = "aa978504bcf76511efdc22d580ba08e2279caab1066b76bb9aa81c4a1e0a32a5";
            };

            beamDeps = [
              expo
            ];
          };
        in
        drv;

      git_diff =
        let
          version = "0.6.4";
          drv = buildMix {
            inherit version;
            name = "git_diff";
            appConfigPath = ./config;

            src = fetchHex {
              inherit version;
              pkg = "git_diff";
              sha256 = "9e05563c136c91e960a306fd296156b2e8d74e294ae60961e69a36e118023a5f";
            };
          };
        in
        drv;

      glob_ex =
        let
          version = "0.1.11";
          drv = buildMix {
            inherit version;
            name = "glob_ex";
            appConfigPath = ./config;

            src = fetchHex {
              inherit version;
              pkg = "glob_ex";
              sha256 = "342729363056e3145e61766b416769984c329e4378f1d558b63e341020525de4";
            };
          };
        in
        drv;

      gproc =
        let
          version = "0.9.1";
          drv = buildRebar3 {
            inherit version;
            name = "gproc";

            src = fetchHex {
              inherit version;
              pkg = "gproc";
              sha256 = "905088e32e72127ed9466f0bac0d8e65704ca5e73ee5a62cb073c3117916d507";
            };
          };
        in
        drv;

      grpcbox =
        let
          version = "0.17.1";
          drv = buildRebar3 {
            inherit version;
            name = "grpcbox";

            src = fetchHex {
              inherit version;
              pkg = "grpcbox";
              sha256 = "4a3b5d7111daabc569dc9cbd9b202a3237d81c80bf97212fbc676832cb0ceb17";
            };

            beamDeps = [
              acceptor_pool
              chatterbox
              ctx
              gproc
            ];
          };
        in
        drv;

      hackney =
        let
          version = "1.25.0";
          drv = buildRebar3 {
            inherit version;
            name = "hackney";

            src = fetchHex {
              inherit version;
              pkg = "hackney";
              sha256 = "7209bfd75fd1f42467211ff8f59ea74d6f2a9e81cbcee95a56711ee79fd6b1d4";
            };

            beamDeps = [
              certifi
              idna
              metrics
              mimerl
              parse_trans
              ssl_verify_fun
              unicode_util_compat
            ];
          };
        in
        drv;

      hammer =
        let
          version = "7.1.0";
          drv = buildMix {
            inherit version;
            name = "hammer";
            appConfigPath = ./config;

            src = fetchHex {
              inherit version;
              pkg = "hammer";
              sha256 = "0ef3f0b9b92ae10a01604ca58adc2bfc8df0af4414a3afcf2dd79e256bc94c17";
            };
          };
        in
        drv;

      hpack =
        let
          version = "0.3.0";
          drv = buildRebar3 {
            inherit version;
            name = "hpack";

            src = fetchHex {
              inherit version;
              pkg = "hpack_erl";
              sha256 = "d6137d7079169d8c485c6962dfe261af5b9ef60fbc557344511c1e65e3d95fb0";
            };
          };
        in
        drv;

      hpax =
        let
          version = "1.0.3";
          drv = buildMix {
            inherit version;
            name = "hpax";
            appConfigPath = ./config;

            src = fetchHex {
              inherit version;
              pkg = "hpax";
              sha256 = "8eab6e1cfa8d5918c2ce4ba43588e894af35dbd8e91e6e55c817bca5847df34a";
            };
          };
        in
        drv;

      html_entities =
        let
          version = "0.5.2";
          drv = buildMix {
            inherit version;
            name = "html_entities";
            appConfigPath = ./config;

            src = fetchHex {
              inherit version;
              pkg = "html_entities";
              sha256 = "c53ba390403485615623b9531e97696f076ed415e8d8058b1dbaa28181f4fdcc";
            };
          };
        in
        drv;

      html_sanitize_ex =
        let
          version = "1.4.3";
          drv = buildMix {
            inherit version;
            name = "html_sanitize_ex";
            appConfigPath = ./config;

            src = fetchHex {
              inherit version;
              pkg = "html_sanitize_ex";
              sha256 = "87748d3c4afe949c7c6eb7150c958c2bcba43fc5b2a02686af30e636b74bccb7";
            };

            beamDeps = [
              mochiweb
            ];
          };
        in
        drv;

      http_signatures =
        let
          version = "0.1.1";
          drv = buildMix {
            inherit version;
            name = "http_signatures";
            appConfigPath = ./config;

            src = pkgs.fetchFromGitHub {
              owner = "bonfire-networks";
              repo = "http_signatures";
              rev = "276839e90e8d2fb17d415502c6c5f0e3f744e88f";
              hash = "sha256-v/OiMkpHL1ytbf8JSsgIzbZMT8Qoffptmt29y+mmjFo=";
            };

            beamDeps = [
              untangle
            ];
          };
        in
        drv;

      httpoison =
        let
          version = "2.2.3";
          drv = buildMix {
            inherit version;
            name = "httpoison";
            appConfigPath = ./config;

            src = fetchHex {
              inherit version;
              pkg = "httpoison";
              sha256 = "fa0f2e3646d3762fdc73edb532104c8619c7636a6997d20af4003da6cfc53e53";
            };

            beamDeps = [
              hackney
            ];
          };
        in
        drv;

      iconify_ex =
        let
          version = "0.6.1";
          drv = buildMix {
            inherit version;
            name = "iconify_ex";
            appConfigPath = ./config;

            src = pkgs.fetchFromGitHub {
              owner = "bonfire-networks";
              repo = "iconify_ex";
              rev = "5d1c2ca0c65377ef88b80f05cc89c3fcef423bf9";
              hash = "sha256-TgOLXgkB/VffErBsZLe0CS6Eg1HPQyYtHMvNC/1L2bE=";
            };

            beamDeps = [
              emote
              jason
              phoenix_live_view
              surface
              phoenix_live_favicon
              recase
              arrows
              untangle
              floki
            ];
          };
        in
        drv;

      idna =
        let
          version = "6.1.1";
          drv = buildRebar3 {
            inherit version;
            name = "idna";

            src = fetchHex {
              inherit version;
              pkg = "idna";
              sha256 = "92376eb7894412ed19ac475e4a86f7b413c1b9fbb5bd16dccd57934157944cea";
            };

            beamDeps = [
              unicode_util_compat
            ];
          };
        in
        drv;

      igniter =
        let
          version = "0.6.30";
          drv = buildMix {
            inherit version;
            name = "igniter";
            appConfigPath = ./config;

            src = fetchHex {
              inherit version;
              pkg = "igniter";
              sha256 = "76a14d5b7f850bb03b5243088c3649d54a2e52e34a2aa1104dee23cf50a8bae0";
            };

            beamDeps = [
              glob_ex
              jason
              owl
              req
              rewrite
              sourceror
              spitfire
            ];
          };
        in
        drv;

      image =
        let
          version = "0.62.1";
          drv = buildMix {
            inherit version;
            name = "image";
            appConfigPath = ./config;

            src = fetchHex {
              inherit version;
              pkg = "image";
              sha256 = "5a5a7acaf68cfaed8932d478b95152cd7d84071442cac558c59f2d31427e91ab";
            };

            beamDeps = [
              evision
              jason
              nx
              phoenix_html
              plug
              req
              rustler
              sweet_xml
              vix
            ];
          };
        in
        drv;

      jason =
        let
          version = "1.4.4";
          drv = buildMix {
            inherit version;
            name = "jason";
            appConfigPath = ./config;

            src = fetchHex {
              inherit version;
              pkg = "jason";
              sha256 = "c5eb0cab91f094599f94d55bc63409236a8ec69a21a67814529e8d5f6cc90b3b";
            };

            beamDeps = [
              decimal
            ];
          };
        in
        drv;

      joken =
        let
          version = "2.6.2";
          drv = buildMix {
            inherit version;
            name = "joken";
            appConfigPath = ./config;

            src = fetchHex {
              inherit version;
              pkg = "joken";
              sha256 = "5134b5b0a6e37494e46dbf9e4dad53808e5e787904b7c73972651b51cce3d72b";
            };

            beamDeps = [
              jose
            ];
          };
        in
        drv;

      jose =
        let
          version = "1.11.10";
          drv = buildMix {
            inherit version;
            name = "jose";
            appConfigPath = ./config;

            src = fetchHex {
              inherit version;
              pkg = "jose";
              sha256 = "0d6cd36ff8ba174db29148fc112b5842186b68a90ce9fc2b3ec3afe76593e614";
            };
          };
        in
        drv;

      json_serde =
        let
          version = "1.1.1";
          drv = buildMix {
            inherit version;
            name = "json_serde";
            appConfigPath = ./config;

            src = fetchHex {
              inherit version;
              pkg = "json_serde";
              sha256 = "0a7acdfac16efceb5337547e98418d3de083c066bbc05f3b5dd96c434d533922";
            };

            beamDeps = [
              brex_result
              decimal
              jason
            ];
          };
        in
        drv;

      jumper =
        let
          version = "1.0.2";
          drv = buildMix {
            inherit version;
            name = "jumper";
            appConfigPath = ./config;

            src = fetchHex {
              inherit version;
              pkg = "jumper";
              sha256 = "9b7782409021e01ab3c08270e26f36eb62976a38c1aa64b2eaf6348422f165e1";
            };
          };
        in
        drv;

      lazy_html =
        let
          version = "0.1.7";
          drv = buildMix {
            inherit version;
            name = "lazy_html";
            appConfigPath = ./config;

            nativeBuildInputs = with pkgs; [
              cmake
              lexbor
            ];

            src = fetchHex {
              inherit version;
              pkg = "lazy_html";
              sha256 = "e115944e6ddb887c45cadfd660348934c318abec0341f7b7156e912b98d3eb95";
            };

            beamDeps = [
              cc_precompiler
              elixir_make
              fine
            ];
          };
        in
        drv.override (workarounds.lazyHtml { } drv);

      linkify =
        let
          version = "0.5.3";
          drv = buildMix {
            inherit version;
            name = "linkify";
            appConfigPath = ./config;

            src = pkgs.fetchFromGitHub {
              owner = "bonfire-networks";
              repo = "linkify";
              rev = "a8c14b67616e63326f901b25f80147a9dbaffd6b";
              hash = "sha256-KTkFPVzgTpB4TIw6IVWidsHJ/bviC674nproky6FouM=";
            };

            beamDeps = [
              untangle
            ];
          };
        in
        drv;

      live_select =
        let
          version = "1.7.0";
          drv = buildMix {
            inherit version;
            name = "live_select";
            appConfigPath = ./config;

            src = fetchHex {
              inherit version;
              pkg = "live_select";
              sha256 = "8e43c98e9adb7bc883845503b7a8388a37c23b98dfd3cd10bf310854bcf3a81c";
            };

            beamDeps = [
              ecto
              phoenix
              phoenix_html
              phoenix_html_helpers
              phoenix_live_view
            ];
          };
        in
        drv;

      mail =
        let
          version = "0.4.4";
          drv = buildMix {
            inherit version;
            name = "mail";
            appConfigPath = ./config;

            src = fetchHex {
              inherit version;
              pkg = "mail";
              sha256 = "bd44bf3e253d8be9c7f2e59b3253aff1efc1c9fa7d8ab4430c96780683faa8e2";
            };
          };
        in
        drv;

      makeup =
        let
          version = "1.2.1";
          drv = buildMix {
            inherit version;
            name = "makeup";
            appConfigPath = ./config;

            src = fetchHex {
              inherit version;
              pkg = "makeup";
              sha256 = "d36484867b0bae0fea568d10131197a4c2e47056a6fbe84922bf6ba71c8d17ce";
            };

            beamDeps = [
              nimble_parsec
            ];
          };
        in
        drv;

      makeup_diff =
        let
          version = "0.1.1";
          drv = buildMix {
            inherit version;
            name = "makeup_diff";
            appConfigPath = ./config;

            src = fetchHex {
              inherit version;
              pkg = "makeup_diff";
              sha256 = "fadb0bf014bd328badb7be986eadbce1a29955dd51c27a9e401c3045cf24184e";
            };

            beamDeps = [
              makeup
            ];
          };
        in
        drv;

      makeup_eex =
        let
          version = "2.0.2";
          drv = buildMix {
            inherit version;
            name = "makeup_eex";
            appConfigPath = ./config;

            src = fetchHex {
              inherit version;
              pkg = "makeup_eex";
              sha256 = "30ac121dda580298ff3378324ffaec94aad5a5b67e0cc6af177c67d5f45629b9";
            };

            beamDeps = [
              makeup
              makeup_elixir
              makeup_html
              nimble_parsec
            ];
          };
        in
        drv;

      makeup_elixir =
        let
          version = "1.0.1";
          drv = buildMix {
            inherit version;
            name = "makeup_elixir";
            appConfigPath = ./config;

            src = fetchHex {
              inherit version;
              pkg = "makeup_elixir";
              sha256 = "7284900d412a3e5cfd97fdaed4f5ed389b8f2b4cb49efc0eb3bd10e2febf9507";
            };

            beamDeps = [
              makeup
              nimble_parsec
            ];
          };
        in
        drv;

      makeup_erlang =
        let
          version = "1.0.2";
          drv = buildMix {
            inherit version;
            name = "makeup_erlang";
            appConfigPath = ./config;

            src = fetchHex {
              inherit version;
              pkg = "makeup_erlang";
              sha256 = "af33ff7ef368d5893e4a267933e7744e46ce3cf1f61e2dccf53a111ed3aa3727";
            };

            beamDeps = [
              makeup
            ];
          };
        in
        drv;

      makeup_graphql =
        let
          version = "0.1.2";
          drv = buildMix {
            inherit version;
            name = "makeup_graphql";
            appConfigPath = ./config;

            src = fetchHex {
              inherit version;
              pkg = "makeup_graphql";
              sha256 = "3390ab04ba388d52a94bbe64ef62aa4d7923ceaffac43ec948f58f631440e8fb";
            };

            beamDeps = [
              makeup
              nimble_parsec
            ];
          };
        in
        drv;

      makeup_html =
        let
          version = "0.2.0";
          drv = buildMix {
            inherit version;
            name = "makeup_html";
            appConfigPath = ./config;

            src = fetchHex {
              inherit version;
              pkg = "makeup_html";
              sha256 = "0856f7beb9a6a642ab1307e06d990fe39f0ba58690d0b8e662aa2e027ba331b2";
            };

            beamDeps = [
              makeup
            ];
          };
        in
        drv;

      makeup_js =
        let
          version = "0.1.0";
          drv = buildMix {
            inherit version;
            name = "makeup_js";
            appConfigPath = ./config;

            src = fetchHex {
              inherit version;
              pkg = "makeup_js";
              sha256 = "3f0c1a5eb52c9737b1679c926574e83bb260ccdedf08b58ee96cca7c685dea75";
            };

            beamDeps = [
              makeup
            ];
          };
        in
        drv;

      makeup_json =
        let
          version = "1.0.0";
          drv = buildMix {
            inherit version;
            name = "makeup_json";
            appConfigPath = ./config;

            src = fetchHex {
              inherit version;
              pkg = "makeup_json";
              sha256 = "5c8c559e658c7f7e91b96c4b8c40f5912ea0adff44b7afe73e4639d9c3f53b94";
            };

            beamDeps = [
              makeup
              nimble_parsec
            ];
          };
        in
        drv;

      makeup_sql =
        let
          version = "0.1.2";
          drv = buildMix {
            inherit version;
            name = "makeup_sql";
            appConfigPath = ./config;

            src = fetchHex {
              inherit version;
              pkg = "makeup_sql";
              sha256 = "46cda46d2857c050939d4dff9094313da79ffd7a0e0f29c76f7cb81a34cb4569";
            };

            beamDeps = [
              makeup
              nimble_parsec
            ];
          };
        in
        drv;

      mdex =
        let
          version = "0.8.4";
          drv = buildMix {
            inherit version;
            name = "mdex";
            appConfigPath = ./config;

            src = fetchHex {
              inherit version;
              pkg = "mdex";
              sha256 = "7854a147557f725356f8774d43fea01ed44fe1bb6dee2247bfd19568c6e97048";
            };

            beamDeps = [
              autumn
              jason
              nimble_options
              rustler
              rustler_precompiled
            ];
          };
        in
        drv.override (workarounds.rustlerPrecompiled { } drv);

      meilisearch_ex =
        let
          version = "1.2.2";
          drv = buildMix {
            inherit version;
            name = "meilisearch_ex";
            appConfigPath = ./config;

            src = fetchHex {
              inherit version;
              pkg = "meilisearch_ex";
              sha256 = "f87769390877c5fc7b0698c42e8508dd6e15fe03c0cb055f9acc2ac5b38618f3";
            };

            beamDeps = [
              ecto
              jason
              tesla
              typed_ecto_schema
            ];
          };
        in
        drv;

      metrics =
        let
          version = "1.0.1";
          drv = buildRebar3 {
            inherit version;
            name = "metrics";

            src = fetchHex {
              inherit version;
              pkg = "metrics";
              sha256 = "69b09adddc4f74a40716ae54d140f93beb0fb8978d8636eaded0c31b6f099f16";
            };
          };
        in
        drv;

      mfm_parser =
        let
          version = "0.2.0";
          drv = buildMix {
            inherit version;
            name = "mfm_parser";
            appConfigPath = ./config;

            src = builtins.fetchGit {
              url = "https://akkoma.dev/AkkomaGang/mfm-parser.git";
              rev = "360a30267a847810a63ab48f606ba227b2ca05f0";
              allRefs = true;
            };
          };
        in
        drv;

      mime =
        let
          version = "2.0.7";
          drv = buildMix {
            inherit version;
            name = "mime";
            appConfigPath = ./config;

            src = fetchHex {
              inherit version;
              pkg = "mime";
              sha256 = "6171188e399ee16023ffc5b76ce445eb6d9672e2e241d2df6050f3c771e80ccd";
            };
          };
        in
        drv;

      mimerl =
        let
          version = "1.4.0";
          drv = buildRebar3 {
            inherit version;
            name = "mimerl";

            src = fetchHex {
              inherit version;
              pkg = "mimerl";
              sha256 = "13af15f9f68c65884ecca3a3891d50a7b57d82152792f3e19d88650aa126b144";
            };
          };
        in
        drv;

      mimetype_parser =
        let
          version = "0.1.3";
          drv = buildMix {
            inherit version;
            name = "mimetype_parser";
            appConfigPath = ./config;

            src = fetchHex {
              inherit version;
              pkg = "mimetype_parser";
              sha256 = "7d8f80c567807ce78cd93c938e7f4b0a20b1aaaaab914bf286f68457d9f7a852";
            };
          };
        in
        drv;

      mint =
        let
          version = "1.7.1";
          drv = buildMix {
            inherit version;
            name = "mint";
            appConfigPath = ./config;

            src = fetchHex {
              inherit version;
              pkg = "mint";
              sha256 = "fceba0a4d0f24301ddee3024ae116df1c3f4bb7a563a731f45fdfeb9d39a231b";
            };

            beamDeps = [
              castore
              hpax
            ];
          };
        in
        drv;

      mjml =
        let
          version = "5.2.0";
          drv = buildMix {
            inherit version;
            name = "mjml";
            appConfigPath = ./config;

            src = fetchHex {
              inherit version;
              pkg = "mjml";
              sha256 = "bf39d2e0041f1f08afd07694239be39a8c173b00649e3463c2bd959473092c2a";
            };

            beamDeps = [
              rustler
              rustler_precompiled
            ];
          };
        in
        drv.override (workarounds.rustlerPrecompiled { } drv);

      mochiweb =
        let
          version = "3.2.2";
          drv = buildRebar3 {
            inherit version;
            name = "mochiweb";

            src = fetchHex {
              inherit version;
              pkg = "mochiweb";
              sha256 = "4114e51f1b44c270b3242d91294fe174ce1ed989100e8b65a1fab58e0cba41d5";
            };
          };
        in
        drv;

      mogrify =
        let
          version = "0.9.3";
          drv = buildMix {
            inherit version;
            name = "mogrify";
            appConfigPath = ./config;

            src = fetchHex {
              inherit version;
              pkg = "mogrify";
              sha256 = "0189b1e1de27455f2b9ae8cf88239cefd23d38de9276eb5add7159aea51731e6";
            };
          };
        in
        drv;

      mua =
        let
          version = "0.2.5";
          drv = buildMix {
            inherit version;
            name = "mua";
            appConfigPath = ./config;

            src = fetchHex {
              inherit version;
              pkg = "mua";
              sha256 = "0e2b18024d0db8943a68e84fb5e2253d3225c8f61d8387cbfc581d66e34d8493";
            };

            beamDeps = [
              castore
            ];
          };
        in
        drv;

      nebulex =
        let
          version = "2.6.5";
          drv = buildMix {
            inherit version;
            name = "nebulex";
            appConfigPath = ./config;

            src = fetchHex {
              inherit version;
              pkg = "nebulex";
              sha256 = "4eb4092058ba53289cb4d5a1b109de6fd094883dfc84a1c2f2ccc57e61a24935";
            };

            beamDeps = [
              decorator
              shards
              telemetry
            ];
          };
        in
        drv;

      needle =
        let
          version = "0.8.0";
          drv = buildMix {
            inherit version;
            name = "needle";
            appConfigPath = ./config;

            src = pkgs.fetchFromGitHub {
              owner = "bonfire-networks";
              repo = "needle";
              rev = "f8dfa30265e0d1b6e2a31dc0688fdbce36044a3b";
              hash = "sha256-GAfThwv//AqGBahzp8f1A70g5rKDdNX1WHvucfae6Ww=";
            };

            beamDeps = [
              ecto_sql
              typed_ecto_schema
              exto
              needle_uid
              telemetry
            ];
          };
        in
        drv;

      needle_uid =
        let
          version = "0.0.1";
          drv = buildMix {
            inherit version;
            name = "needle_uid";
            appConfigPath = ./config;

            src = pkgs.fetchFromGitHub {
              owner = "bonfire-networks";
              repo = "needle_uid";
              rev = "3ec02ce42d96498db286a619a31a40eda2df7fa7";
              hash = "sha256-jf6PNnv74hx4GKQgmdThY1Sn4yet4DIPkeN4yVk6scw=";
            };

            beamDeps = [
              ecto
              untangle
              needle_ulid
            ];
          };
        in
        drv;

      needle_ulid =
        let
          version = "0.4.0";
          drv = buildMix {
            inherit version;
            name = "needle_ulid";
            appConfigPath = ./config;

            src = pkgs.fetchFromGitHub {
              owner = "bonfire-networks";
              repo = "needle_ulid";
              rev = "f26b7c782633e373bc61354d263b0eb7ba0151a4";
              hash = "sha256-1fvRtaIui9e8li+ZxbyZC1Aqo8UDX0jCEfEINPKbAJQ=";
            };

            beamDeps = [
              ex_ulid
              ecto
              ecto_sql
            ];
          };
        in
        drv;

      nimble_csv =
        let
          version = "1.3.0";
          drv = buildMix {
            inherit version;
            name = "nimble_csv";
            appConfigPath = ./config;

            src = fetchHex {
              inherit version;
              pkg = "nimble_csv";
              sha256 = "41ccdc18f7c8f8bb06e84164fc51635321e80d5a3b450761c4997d620925d619";
            };
          };
        in
        drv;

      nimble_options =
        let
          version = "1.1.1";
          drv = buildMix {
            inherit version;
            name = "nimble_options";
            appConfigPath = ./config;

            src = fetchHex {
              inherit version;
              pkg = "nimble_options";
              sha256 = "821b2470ca9442c4b6984882fe9bb0389371b8ddec4d45a9504f00a66f650b44";
            };
          };
        in
        drv;

      nimble_ownership =
        let
          version = "1.0.1";
          drv = buildMix {
            inherit version;
            name = "nimble_ownership";
            appConfigPath = ./config;

            src = fetchHex {
              inherit version;
              pkg = "nimble_ownership";
              sha256 = "3825e461025464f519f3f3e4a1f9b68c47dc151369611629ad08b636b73bb22d";
            };
          };
        in
        drv;

      nimble_parsec =
        let
          version = "1.4.2";
          drv = buildMix {
            inherit version;
            name = "nimble_parsec";
            appConfigPath = ./config;

            src = fetchHex {
              inherit version;
              pkg = "nimble_parsec";
              sha256 = "4b21398942dda052b403bbe1da991ccd03a053668d147d53fb8c4e0efe09c973";
            };
          };
        in
        drv;

      nimble_pool =
        let
          version = "1.1.0";
          drv = buildMix {
            inherit version;
            name = "nimble_pool";
            appConfigPath = ./config;

            src = fetchHex {
              inherit version;
              pkg = "nimble_pool";
              sha256 = "af2e4e6b34197db81f7aad230c1118eac993acc0dae6bc83bac0126d4ae0813a";
            };
          };
        in
        drv;

      nodeinfo =
        let
          version = "0.1.0";
          drv = buildMix {
            inherit version;
            name = "nodeinfo";
            appConfigPath = ./config;

            src = pkgs.fetchFromGitHub {
              owner = "bonfire-networks";
              repo = "nodeinfo";
              rev = "0b2521e3d2559253b6133ba31c7c86a858587cc4";
              hash = "sha256-H7Np3mWsbuZDxEbDIZayMX+hRLuOq4Z58QKZyEEZ6Ig=";
            };

            beamDeps = [
              phoenix
              postgrex
              gettext
              jason
              plug_cowboy
            ];
          };
        in
        drv;

      nx =
        let
          version = "0.10.0";
          drv = buildMix {
            inherit version;
            name = "nx";
            appConfigPath = ./config;

            src = fetchHex {
              inherit version;
              pkg = "nx";
              sha256 = "3db8892c124aeee091df0e6fbf8e5bf1b81f502eb0d4f5ba63e6378ebcae7da4";
            };

            beamDeps = [
              complex
              telemetry
            ];
          };
        in
        drv;

      oban =
        let
          version = "2.20.1";
          drv = buildMix {
            inherit version;
            name = "oban";
            appConfigPath = ./config;

            src = fetchHex {
              inherit version;
              pkg = "oban";
              sha256 = "17a45277dbeb41a455040b41dd8c467163fad685d1366f2f59207def3bcdd1d8";
            };

            beamDeps = [
              ecto_sql
              igniter
              jason
              postgrex
              telemetry
            ];
          };
        in
        drv;

      oban_met =
        let
          version = "1.0.3";
          drv = buildMix {
            inherit version;
            name = "oban_met";
            appConfigPath = ./config;

            src = fetchHex {
              inherit version;
              pkg = "oban_met";
              sha256 = "23db1a0ee58b93afe324b221530594bdf3647a9bd4e803af762c3e00ad74b9cf";
            };

            beamDeps = [
              oban
            ];
          };
        in
        drv;

      oban_web =
        let
          version = "2.11.4";
          drv = buildMix {
            inherit version;
            name = "oban_web";
            appConfigPath = ./config;

            src = fetchHex {
              inherit version;
              pkg = "oban_web";
              sha256 = "deb38825311f53cee5fc89c3ea78e0a2a60095b63643517649f76fb5563031db";
            };

            beamDeps = [
              jason
              oban
              oban_met
              phoenix
              phoenix_html
              phoenix_live_view
              phoenix_pubsub
            ];
          };
        in
        drv;

      openid_connect =
        let
          version = "1.0.0";
          drv = buildMix {
            inherit version;
            name = "openid_connect";
            appConfigPath = ./config;

            src = fetchHex {
              inherit version;
              pkg = "openid_connect";
              sha256 = "1abc2009fad37321996b64ac4b36d8113b309b697707c0774ed6d3dbad9a5005";
            };

            beamDeps = [
              finch
              jason
              jose
            ];
          };
        in
        drv;

      opentelemetry =
        let
          version = "1.5.1";
          drv = buildRebar3 {
            inherit version;
            name = "opentelemetry";

            src = fetchHex {
              inherit version;
              pkg = "opentelemetry";
              sha256 = "27c6775b2b609bb28bd9c1c0cb2dee907bfed2e31fcf0afd9b8e3fad27ef1382";
            };

            beamDeps = [
              opentelemetry_api
            ];
          };
        in
        drv;

      opentelemetry_api =
        let
          version = "1.4.1";
          drv = buildMix {
            inherit version;
            name = "opentelemetry_api";
            appConfigPath = ./config;

            src = fetchHex {
              inherit version;
              pkg = "opentelemetry_api";
              sha256 = "39bdb6ad740bc13b16215cb9f233d66796bbae897f3bf6eb77abb712e87c3c26";
            };
          };
        in
        drv;

      opentelemetry_exporter =
        let
          version = "1.8.1";
          drv = buildRebar3 {
            inherit version;
            name = "opentelemetry_exporter";

            src = fetchHex {
              inherit version;
              pkg = "opentelemetry_exporter";
              sha256 = "0a64b2889aa87f38f0b3afcebe1f0a50c52b7e956fe6e535668741561c753e97";
            };

            beamDeps = [
              grpcbox
              opentelemetry
              opentelemetry_api
              tls_certificate_check
            ];
          };
        in
        drv;

      opentelemetry_process_propagator =
        let
          version = "0.3.0";
          drv = buildMix {
            inherit version;
            name = "opentelemetry_process_propagator";
            appConfigPath = ./config;

            src = fetchHex {
              inherit version;
              pkg = "opentelemetry_process_propagator";
              sha256 = "7243cb6de1523c473cba5b1aefa3f85e1ff8cc75d08f367104c1e11919c8c029";
            };

            beamDeps = [
              opentelemetry_api
            ];
          };
        in
        drv;

      opentelemetry_semantic_conventions =
        let
          version = "1.27.0";
          drv = buildMix {
            inherit version;
            name = "opentelemetry_semantic_conventions";
            appConfigPath = ./config;

            src = fetchHex {
              inherit version;
              pkg = "opentelemetry_semantic_conventions";
              sha256 = "9681ccaa24fd3d810b4461581717661fd85ff7019b082c2dff89c7d5b1fc2864";
            };
          };
        in
        drv;

      orion =
        let
          version = "1.0.7";
          drv = buildMix {
            inherit version;
            name = "orion";
            appConfigPath = ./config;

            src = fetchHex {
              inherit version;
              pkg = "orion";
              sha256 = "e8096ac94d684c0b80d3fbeb704243bb4b349831755bbe145f7814bba186aab4";
            };

            beamDeps = [
              dog_sketch
              jason
              orion_collector
              phoenix_html_helpers
              phoenix_live_view
            ];
          };
        in
        drv;

      orion_collector =
        let
          version = "1.2.0";
          drv = buildMix {
            inherit version;
            name = "orion_collector";
            appConfigPath = ./config;

            src = fetchHex {
              inherit version;
              pkg = "orion_collector";
              sha256 = "f6eb4687123c5845da2bb82002babdaf87ccb8ddb3762cde304aa09f24832422";
            };

            beamDeps = [
              dog_sketch
              ex2ms
            ];
          };
        in
        drv;

      owl =
        let
          version = "0.13.0";
          drv = buildMix {
            inherit version;
            name = "owl";
            appConfigPath = ./config;

            src = fetchHex {
              inherit version;
              pkg = "owl";
              sha256 = "59bf9d11ce37a4db98f57cb68fbfd61593bf419ec4ed302852b6683d3d2f7475";
            };
          };
        in
        drv;

      paginator =
        let
          version = "1.0.4";
          drv = buildMix {
            inherit version;
            name = "paginator";
            appConfigPath = ./config;

            src = pkgs.fetchFromGitHub {
              owner = "bonfire-networks";
              repo = "paginator";
              rev = "faa9909568c86b74838ef5d036fecb003ea77c1f";
              hash = "sha256-wDsBGnGV4wqI02YBlZGlBEffKIMHU/ANtgzoKIWj+nU=";
            };

            beamDeps = [
              ecto
              ecto_sql
              postgrex
              plug_crypto
              needle_uid
              untangle
            ];
          };
        in
        drv;

      pane =
        let
          version = "0.5.0";
          drv = buildMix {
            inherit version;
            name = "pane";
            appConfigPath = ./config;

            src = fetchHex {
              inherit version;
              pkg = "pane";
              sha256 = "71ad875092bff3c249195881a56df836ca5f9f2dcd668a21dd2b1b5d9549b7b9";
            };
          };
        in
        drv;

      parse_trans =
        let
          version = "3.4.1";
          drv = buildRebar3 {
            inherit version;
            name = "parse_trans";

            src = fetchHex {
              inherit version;
              pkg = "parse_trans";
              sha256 = "620a406ce75dada827b82e453c19cf06776be266f5a67cff34e1ef2cbb60e49a";
            };
          };
        in
        drv;

      patch =
        let
          version = "0.15.0";
          drv = buildMix {
            inherit version;
            name = "patch";
            appConfigPath = ./config;

            src = fetchHex {
              inherit version;
              pkg = "patch";
              sha256 = "e8dadf9b57b30e92f6b2b1ce2f7f57700d14c66d4ed56ee27777eb73fb77e58d";
            };
          };
        in
        drv;

      pathex =
        let
          version = "2.6.1";
          drv = buildMix {
            inherit version;
            name = "pathex";
            appConfigPath = ./config;

            src = fetchHex {
              inherit version;
              pkg = "pathex";
              sha256 = "159f8e4b5fa2eaa887777070f7a5d3006601f7085efb4d76c0cef0f2ec9c4be9";
            };
          };
        in
        drv;

      phoenix =
        let
          version = "1.8.1";
          drv = buildMix {
            inherit version;
            name = "phoenix";
            appConfigPath = ./config;

            src = fetchHex {
              inherit version;
              pkg = "phoenix";
              sha256 = "84d77d2b2e77c3c7e7527099bd01ef5c8560cd149c036d6b3a40745f11cd2fb2";
            };

            beamDeps = [
              bandit
              jason
              phoenix_pubsub
              phoenix_template
              phoenix_view
              plug
              plug_cowboy
              plug_crypto
              telemetry
              websock_adapter
            ];
          };
        in
        drv;

      phoenix_ecto =
        let
          version = "4.6.5";
          drv = buildMix {
            inherit version;
            name = "phoenix_ecto";
            appConfigPath = ./config;

            src = fetchHex {
              inherit version;
              pkg = "phoenix_ecto";
              sha256 = "26ec3208eef407f31b748cadd044045c6fd485fbff168e35963d2f9dfff28d4b";
            };

            beamDeps = [
              ecto
              phoenix_html
              plug
              postgrex
            ];
          };
        in
        drv;

      phoenix_gon =
        let
          version = "0.4.0";
          drv = buildMix {
            inherit version;
            name = "phoenix_gon";
            appConfigPath = ./config;

            src = pkgs.fetchFromGitHub {
              owner = "bonfire-networks";
              repo = "phoenix_gon";
              rev = "47db70596e42077f67b4b7a1df158322e65ee0ed";
              hash = "sha256-7ASitDGIJCmDjaE3q9Z7dyaR76BR4k7tU0GHYOyzUHE=";
            };

            beamDeps = [
              jason
              phoenix_html
              phoenix_html_helpers
              plug
              recase
            ];
          };
        in
        drv;

      phoenix_html =
        let
          version = "4.3.0";
          drv = buildMix {
            inherit version;
            name = "phoenix_html";
            appConfigPath = ./config;

            src = fetchHex {
              inherit version;
              pkg = "phoenix_html";
              sha256 = "3eaa290a78bab0f075f791a46a981bbe769d94bc776869f4f3063a14f30497ad";
            };
          };
        in
        drv;

      phoenix_html_helpers =
        let
          version = "1.0.1";
          drv = buildMix {
            inherit version;
            name = "phoenix_html_helpers";
            appConfigPath = ./config;

            src = fetchHex {
              inherit version;
              pkg = "phoenix_html_helpers";
              sha256 = "cffd2385d1fa4f78b04432df69ab8da63dc5cf63e07b713a4dcf36a3740e3090";
            };

            beamDeps = [
              phoenix_html
              plug
            ];
          };
        in
        drv;

      phoenix_live_dashboard =
        let
          version = "0.8.7";
          drv = buildMix {
            inherit version;
            name = "phoenix_live_dashboard";
            appConfigPath = ./config;

            src = fetchHex {
              inherit version;
              pkg = "phoenix_live_dashboard";
              sha256 = "3a8625cab39ec261d48a13b7468dc619c0ede099601b084e343968309bd4d7d7";
            };

            beamDeps = [
              ecto
              ecto_psql_extras
              mime
              phoenix_live_view
              telemetry_metrics
            ];
          };
        in
        drv;

      phoenix_live_favicon =
        let
          version = "0.2.0";
          drv = buildMix {
            inherit version;
            name = "phoenix_live_favicon";
            appConfigPath = ./config;

            src = fetchHex {
              inherit version;
              pkg = "phoenix_live_favicon";
              sha256 = "136121d68b30f9344214d37feebf88ee63f1a1948a33251ac80c706cfa7da79e";
            };

            beamDeps = [
              phoenix_live_head
            ];
          };
        in
        drv;

      phoenix_live_head =
        let
          version = "0.2.2";
          drv = buildMix {
            inherit version;
            name = "phoenix_live_head";
            appConfigPath = ./config;

            src = fetchHex {
              inherit version;
              pkg = "phoenix_live_head";
              sha256 = "fdfe3dc85499f7cc277b8d2c973fb50fbde9748cc56664fbe7b9ada8712dba19";
            };

            beamDeps = [
              ex_doc
              jason
              phoenix
              phoenix_html
              phoenix_live_view
            ];
          };
        in
        drv;

      phoenix_live_view =
        let
          version = "1.1.11";
          drv = buildMix {
            inherit version;
            name = "phoenix_live_view";
            appConfigPath = ./config;

            src = fetchHex {
              inherit version;
              pkg = "phoenix_live_view";
              sha256 = "266823602e11a54e562ac03a25b3d232d79de12514262db7cfcbb83fdfd8fd57";
            };

            beamDeps = [
              igniter
              jason
              lazy_html
              phoenix
              phoenix_html
              phoenix_template
              phoenix_view
              plug
              telemetry
            ];
          };
        in
        drv;

      phoenix_pubsub =
        let
          version = "2.2.0";
          drv = buildMix {
            inherit version;
            name = "phoenix_pubsub";
            appConfigPath = ./config;

            src = fetchHex {
              inherit version;
              pkg = "phoenix_pubsub";
              sha256 = "adc313a5bf7136039f63cfd9668fde73bba0765e0614cba80c06ac9460ff3e96";
            };
          };
        in
        drv;

      phoenix_seo =
        let
          version = "0.1.11";
          drv = buildMix {
            inherit version;
            name = "phoenix_seo";
            appConfigPath = ./config;

            src = fetchHex {
              inherit version;
              pkg = "phoenix_seo";
              sha256 = "4cafd9bbe471306dff7905482b7f9c50698790fdb80a2f1e24b2f0dbca7af448";
            };

            beamDeps = [
              phoenix_live_view
            ];
          };
        in
        drv;

      phoenix_template =
        let
          version = "1.0.4";
          drv = buildMix {
            inherit version;
            name = "phoenix_template";
            appConfigPath = ./config;

            src = fetchHex {
              inherit version;
              pkg = "phoenix_template";
              sha256 = "2c0c81f0e5c6753faf5cca2f229c9709919aba34fab866d3bc05060c9c444206";
            };

            beamDeps = [
              phoenix_html
            ];
          };
        in
        drv;

      phoenix_view =
        let
          version = "2.0.4";
          drv = buildMix {
            inherit version;
            name = "phoenix_view";
            appConfigPath = ./config;

            src = fetchHex {
              inherit version;
              pkg = "phoenix_view";
              sha256 = "4e992022ce14f31fe57335db27a28154afcc94e9983266835bb3040243eb620b";
            };

            beamDeps = [
              phoenix_html
              phoenix_template
            ];
          };
        in
        drv;

      plug =
        let
          version = "1.18.1";
          drv = buildMix {
            inherit version;
            name = "plug";
            appConfigPath = ./config;

            src = fetchHex {
              inherit version;
              pkg = "plug";
              sha256 = "57a57db70df2b422b564437d2d33cf8d33cd16339c1edb190cd11b1a3a546cc2";
            };

            beamDeps = [
              mime
              plug_crypto
              telemetry
            ];
          };
        in
        drv;

      plug_cowboy =
        let
          version = "2.7.5";
          drv = buildMix {
            inherit version;
            name = "plug_cowboy";
            appConfigPath = ./config;

            src = fetchHex {
              inherit version;
              pkg = "plug_cowboy";
              sha256 = "20884bf58a90ff5a5663420f5d2c368e9e15ed1ad5e911daf0916ea3c57f77ac";
            };

            beamDeps = [
              cowboy
              cowboy_telemetry
              plug
            ];
          };
        in
        drv;

      plug_crypto =
        let
          version = "2.1.1";
          drv = buildMix {
            inherit version;
            name = "plug_crypto";
            appConfigPath = ./config;

            src = fetchHex {
              inherit version;
              pkg = "plug_crypto";
              sha256 = "6470bce6ffe41c8bd497612ffde1a7e4af67f36a15eea5f921af71cf3e11247c";
            };
          };
        in
        drv;

      plug_early_hints =
        let
          version = "0.1.0";
          drv = buildMix {
            inherit version;
            name = "plug_early_hints";
            appConfigPath = ./config;

            src = fetchHex {
              inherit version;
              pkg = "plug_early_hints";
              sha256 = "f4167b2daecbe39af40718fe0907899f34ef9f19ea11fb184a4732b18dc70e3c";
            };

            beamDeps = [
              plug
            ];
          };
        in
        drv;

      plug_http_validator =
        let
          version = "0.1.0";
          drv = buildMix {
            inherit version;
            name = "plug_http_validator";
            appConfigPath = ./config;

            src = pkgs.fetchFromGitHub {
              owner = "bonfire-networks";
              repo = "plug_http_validator";
              rev = "dbc277f8a328bc44107174fb1770b1376337697a";
              hash = "sha256-6O8jq0YQdT3sGN59xie5RAuGLoHtLl3Qsw3SaXccw1Y=";
            };

            beamDeps = [
              plug
            ];
          };
        in
        drv;

      poison =
        let
          version = "6.0.0";
          drv = buildMix {
            inherit version;
            name = "poison";
            appConfigPath = ./config;

            src = fetchHex {
              inherit version;
              pkg = "poison";
              sha256 = "bb9064632b94775a3964642d6a78281c07b7be1319e0016e1643790704e739a2";
            };

            beamDeps = [
              decimal
            ];
          };
        in
        drv;

      poolboy =
        let
          version = "1.5.2";
          drv = buildRebar3 {
            inherit version;
            name = "poolboy";

            src = fetchHex {
              inherit version;
              pkg = "poolboy";
              sha256 = "dad79704ce5440f3d5a3681c8590b9dc25d1a561e8f5a9c995281012860901e3";
            };
          };
        in
        drv;

      postgrex =
        let
          version = "0.20.0";
          drv = buildMix {
            inherit version;
            name = "postgrex";
            appConfigPath = ./config;

            src = fetchHex {
              inherit version;
              pkg = "postgrex";
              sha256 = "d36ef8b36f323d29505314f704e21a1a038e2dc387c6409ee0cd24144e187c0f";
            };

            beamDeps = [
              db_connection
              decimal
              jason
            ];
          };
        in
        drv;

      process_tree =
        let
          version = "0.2.1";
          drv = buildMix {
            inherit version;
            name = "process_tree";
            appConfigPath = ./config;

            src = fetchHex {
              inherit version;
              pkg = "process_tree";
              sha256 = "68eee6bf0514351aeeda7037f1a6003c0e25de48fe6b7d15a1b0aebb4b35e713";
            };
          };
        in
        drv;

      puid =
        let
          version = "1.1.2";
          drv = buildMix {
            inherit version;
            name = "puid";
            appConfigPath = ./config;

            src = fetchHex {
              inherit version;
              pkg = "puid";
              sha256 = "fbd1691e29e576c4fbf23852f4d256774702ad1f2a91b37e4344f7c278f1ffaa";
            };

            beamDeps = [
              crypto_rand
            ];
          };
        in
        drv;

      ranch =
        let
          version = "1.8.1";
          drv = buildRebar3 {
            inherit version;
            name = "ranch";

            src = fetchHex {
              inherit version;
              pkg = "ranch";
              sha256 = "aed58910f4e21deea992a67bf51632b6d60114895eb03bb392bb733064594dd0";
            };
          };
        in
        drv;

      recase =
        let
          version = "0.9.0";
          drv = buildMix {
            inherit version;
            name = "recase";
            appConfigPath = ./config;

            src = fetchHex {
              inherit version;
              pkg = "recase";
              sha256 = "efa7549ebd128988d1723037a6f6a61948055aec107db6288f1c52830cb6501c";
            };
          };
        in
        drv;

      redirect =
        let
          version = "0.4.0";
          drv = buildMix {
            inherit version;
            name = "redirect";
            appConfigPath = ./config;

            src = fetchHex {
              inherit version;
              pkg = "redirect";
              sha256 = "dfa29a8ecbad066ed0b73b34611cf24c78101719737f37bdf750f39197d67b97";
            };

            beamDeps = [
              phoenix
              plug
            ];
          };
        in
        drv;

      remote_ip =
        let
          version = "1.2.0";
          drv = buildMix {
            inherit version;
            name = "remote_ip";
            appConfigPath = ./config;

            src = fetchHex {
              inherit version;
              pkg = "remote_ip";
              sha256 = "2ff91de19c48149ce19ed230a81d377186e4412552a597d6a5137373e5877cb7";
            };

            beamDeps = [
              combine
              plug
            ];
          };
        in
        drv;

      req =
        let
          version = "0.5.16";
          drv = buildMix {
            inherit version;
            name = "req";
            appConfigPath = ./config;

            src = fetchHex {
              inherit version;
              pkg = "req";
              sha256 = "974a7a27982b9b791df84e8f6687d21483795882a7840e8309abdbe08bb06f09";
            };

            beamDeps = [
              finch
              jason
              mime
              nimble_csv
              plug
            ];
          };
        in
        drv;

      rewrite =
        let
          version = "1.2.0";
          drv = buildMix {
            inherit version;
            name = "rewrite";
            appConfigPath = ./config;

            src = fetchHex {
              inherit version;
              pkg = "rewrite";
              sha256 = "a1cd702bbb9d51613ab21091f04a386d750fc6f4516b81900df082d78b2d8c50";
            };

            beamDeps = [
              glob_ex
              sourceror
              text_diff
            ];
          };
        in
        drv;

      rustler =
        let
          version = "0.37.1";
          drv = buildMix {
            inherit version;
            name = "rustler";
            appConfigPath = ./config;

            src = fetchHex {
              inherit version;
              pkg = "rustler";
              sha256 = "24547e9b8640cf00e6a2071acb710f3e12ce0346692e45098d84d45cdb54fd79";
            };

            beamDeps = [
              jason
            ];
          };
        in
        drv;

      rustler_precompiled =
        let
          version = "0.8.3";
          drv = buildMix {
            inherit version;
            name = "rustler_precompiled";
            appConfigPath = ./config;

            src = fetchHex {
              inherit version;
              pkg = "rustler_precompiled";
              sha256 = "c23f5f33cb6608542de4d04faf0f0291458c352a4648e4d28d17ee1098cddcc4";
            };

            beamDeps = [
              castore
              rustler
            ];
          };
        in
        drv;

      scribe =
        let
          version = "0.11.0";
          drv = buildMix {
            inherit version;
            name = "scribe";
            appConfigPath = ./config;

            src = fetchHex {
              inherit version;
              pkg = "scribe";
              sha256 = "fff15704b6a400125b4200b0bc052e589e831092991140ddb178cc0deb0e7885";
            };

            beamDeps = [
              pane
            ];
          };
        in
        drv;

      secure_random =
        let
          version = "0.5.1";
          drv = buildMix {
            inherit version;
            name = "secure_random";
            appConfigPath = ./config;

            src = fetchHex {
              inherit version;
              pkg = "secure_random";
              sha256 = "1b9754f15e3940a143baafd19da12293f100044df69ea12db5d72878312ae6ab";
            };
          };
        in
        drv;

      sentry =
        let
          version = "11.0.3";
          drv = buildMix {
            inherit version;
            name = "sentry";
            appConfigPath = ./config;

            src = fetchHex {
              inherit version;
              pkg = "sentry";
              sha256 = "a73d405b50fc619b3d65a8f87caae044d6794e2233e56b0cb1c1ea331a9bec94";
            };

            beamDeps = [
              hackney
              igniter
              jason
              nimble_options
              nimble_ownership
              opentelemetry
              opentelemetry_api
              opentelemetry_exporter
              opentelemetry_semantic_conventions
              phoenix
              phoenix_live_view
              plug
              telemetry
            ];
          };
        in
        drv;

      shards =
        let
          version = "1.1.1";
          drv = buildRebar3 {
            inherit version;
            name = "shards";

            src = fetchHex {
              inherit version;
              pkg = "shards";
              sha256 = "169a045dae6668cda15fbf86d31bf433d0dbbaec42c8c23ca4f8f2d405ea8eda";
            };
          };
        in
        drv;

      simple_slug =
        let
          version = "0.1.1";
          drv = buildMix {
            inherit version;
            name = "simple_slug";
            appConfigPath = ./config;

            src = fetchHex {
              inherit version;
              pkg = "simple_slug";
              sha256 = "477c19c7bc8755a1378bdd4ec591e4819071c72353b7e470b90329e63ef67a72";
            };
          };
        in
        drv;

      sizeable =
        let
          version = "1.0.2";
          drv = buildMix {
            inherit version;
            name = "sizeable";
            appConfigPath = ./config;

            src = fetchHex {
              inherit version;
              pkg = "sizeable";
              sha256 = "4bab548e6dfba777b400ca50830a9e3a4128e73df77ab1582540cf5860601762";
            };
          };
        in
        drv;

      sleeplocks =
        let
          version = "1.1.3";
          drv = buildRebar3 {
            inherit version;
            name = "sleeplocks";

            src = fetchHex {
              inherit version;
              pkg = "sleeplocks";
              sha256 = "d3b3958552e6eb16f463921e70ae7c767519ef8f5be46d7696cc1ed649421321";
            };
          };
        in
        drv;

      social =
        let
          version = "0.0.1";
          drv = buildMix {
            inherit version;
            name = "social";
            appConfigPath = ./config;

            src = pkgs.fetchFromGitHub {
              owner = "bonfire-networks";
              repo = "social";
              rev = "0a7721b11a4ca37085560f00c1ee3afcd77dabc9";
              hash = "sha256-HIddOdOsZvRr3ZdkVzZjU0gVEWwBAjdkj1gFXVBArVo=";
            };

            beamDeps = [
              ember
              bonfire_messages
              bonfire_ui_messages
              bonfire_ui_reactions
              bonfire_classify
              bonfire_search
              bonfire_invite_links
              bonfire_data_shared_user
              bonfire_api_graphql
              bonfire_open_id
              bonfire_geolocate
              mfm_parser
              forecastr
              activity_pub
              ecto_sparkles
              needle
              needle_uid
              needle_ulid
              ex_ulid
              absinthe
              eqrcode
              geo_postgis
              geo
              phoenix
              phoenix_live_view
              owl
              httpoison
              poison
              hackney
              rustler_precompiled
              igniter
            ];
          };
        in
        drv.override (workarounds.rustlerPrecompiled { } drv);

      solid =
        let
          version = "0.18.0";
          drv = buildMix {
            inherit version;
            name = "solid";
            appConfigPath = ./config;

            src = fetchHex {
              inherit version;
              pkg = "solid";
              sha256 = "7704681c11c880308fe1337acf7690083f884076b612d38b7dccb5a1bd016068";
            };

            beamDeps = [
              nimble_parsec
            ];
          };
        in
        drv;

      sourceror =
        let
          version = "1.6.0";
          drv = buildMix {
            inherit version;
            name = "sourceror";
            appConfigPath = ./config;

            src = fetchHex {
              inherit version;
              pkg = "sourceror";
              sha256 = "e90aef8c82dacf32c89c8ef83d1416fc343cd3e5556773eeffd2c1e3f991f699";
            };
          };
        in
        drv;

      spitfire =
        let
          version = "0.2.1";
          drv = buildMix {
            inherit version;
            name = "spitfire";
            appConfigPath = ./config;

            src = fetchHex {
              inherit version;
              pkg = "spitfire";
              sha256 = "6eeed75054a38341b2e1814d41bb0a250564092358de2669fdb57ff88141d91b";
            };
          };
        in
        drv;

      ssl_verify_fun =
        let
          version = "1.1.7";
          drv = buildMix {
            inherit version;
            name = "ssl_verify_fun";
            appConfigPath = ./config;

            src = fetchHex {
              inherit version;
              pkg = "ssl_verify_fun";
              sha256 = "fe4c190e8f37401d30167c8c405eda19469f34577987c76dde613e838bbc67f8";
            };
          };
        in
        drv;

      statistex =
        let
          version = "1.1.0";
          drv = buildMix {
            inherit version;
            name = "statistex";
            appConfigPath = ./config;

            src = fetchHex {
              inherit version;
              pkg = "statistex";
              sha256 = "f5950ea26ad43246ba2cce54324ac394a4e7408fdcf98b8e230f503a0cba9cf5";
            };
          };
        in
        drv;

      surface =
        let
          version = "0.12.1";
          drv = buildMix {
            inherit version;
            name = "surface";
            appConfigPath = ./config;

            src = fetchHex {
              inherit version;
              pkg = "surface";
              sha256 = "133242252537f9c41533388607301f3d01755a338482e4288f42343dc20cd413";
            };

            beamDeps = [
              phoenix_live_view
              sourceror
            ];
          };
        in
        drv;

      surface_form_helpers =
        let
          version = "0.2.0";
          drv = buildMix {
            inherit version;
            name = "surface_form_helpers";
            appConfigPath = ./config;

            src = fetchHex {
              inherit version;
              pkg = "surface_form_helpers";
              sha256 = "3491b2c5e5e2f6f1d004bd989557d8df750bf48cc4660671c31b8b07c44dfc22";
            };

            beamDeps = [
              phoenix_html
              phoenix_html_helpers
              surface
            ];
          };
        in
        drv;

      sweet_xml =
        let
          version = "0.7.5";
          drv = buildMix {
            inherit version;
            name = "sweet_xml";
            appConfigPath = ./config;

            src = fetchHex {
              inherit version;
              pkg = "sweet_xml";
              sha256 = "193b28a9b12891cae351d81a0cead165ffe67df1b73fe5866d10629f4faefb12";
            };
          };
        in
        drv;

      swoosh =
        let
          version = "1.19.5";
          drv = buildMix {
            inherit version;
            name = "swoosh";
            appConfigPath = ./config;

            src = fetchHex {
              inherit version;
              pkg = "swoosh";
              sha256 = "c953f51ee0a8b237e0f4307c9cefd3eb1eb751c35fcdda2a8bccb991766473be";
            };

            beamDeps = [
              bandit
              cowboy
              ex_aws
              finch
              gen_smtp
              hackney
              jason
              mail
              mime
              mua
              plug
              plug_cowboy
              req
              telemetry
            ];
          };
        in
        drv;

      table_rex =
        let
          version = "3.1.1";
          drv = buildMix {
            inherit version;
            name = "table_rex";
            appConfigPath = ./config;

            src = fetchHex {
              inherit version;
              pkg = "table_rex";
              sha256 = "678a23aba4d670419c23c17790f9dcd635a4a89022040df7d5d772cb21012490";
            };
          };
        in
        drv;

      telemetry =
        let
          version = "1.3.0";
          drv = buildRebar3 {
            inherit version;
            name = "telemetry";

            src = fetchHex {
              inherit version;
              pkg = "telemetry";
              sha256 = "7015fc8919dbe63764f4b4b87a95b7c0996bd539e0d499be6ec9d7f3875b79e6";
            };
          };
        in
        drv;

      telemetry_metrics =
        let
          version = "1.1.0";
          drv = buildMix {
            inherit version;
            name = "telemetry_metrics";
            appConfigPath = ./config;

            src = fetchHex {
              inherit version;
              pkg = "telemetry_metrics";
              sha256 = "e7b79e8ddfde70adb6db8a6623d1778ec66401f366e9a8f5dd0955c56bc8ce67";
            };

            beamDeps = [
              telemetry
            ];
          };
        in
        drv;

      telemetry_poller =
        let
          version = "1.3.0";
          drv = buildRebar3 {
            inherit version;
            name = "telemetry_poller";

            src = fetchHex {
              inherit version;
              pkg = "telemetry_poller";
              sha256 = "51f18bed7128544a50f75897db9974436ea9bfba560420b646af27a9a9b35211";
            };

            beamDeps = [
              telemetry
            ];
          };
        in
        drv;

      tesla =
        let
          version = "1.15.3";
          drv = buildMix {
            inherit version;
            name = "tesla";
            appConfigPath = ./config;

            src = fetchHex {
              inherit version;
              pkg = "tesla";
              sha256 = "98bb3d4558abc67b92fb7be4cd31bb57ca8d80792de26870d362974b58caeda7";
            };

            beamDeps = [
              castore
              finch
              hackney
              jason
              mime
              mint
              poison
              telemetry
            ];
          };
        in
        drv;

      text =
        let
          version = "0.2.0";
          drv = buildMix {
            inherit version;
            name = "text";
            appConfigPath = ./config;

            src = fetchHex {
              inherit version;
              pkg = "text";
              sha256 = "5ca265ba24bd2f00ab647dd524305e24cc17224b4f0052f169ff488013888bc3";
            };

            beamDeps = [
              flow
            ];
          };
        in
        drv;

      text_corpus_udhr =
        let
          version = "0.1.0";
          drv = buildMix {
            inherit version;
            name = "text_corpus_udhr";
            appConfigPath = ./config;

            src = fetchHex {
              inherit version;
              pkg = "text_corpus_udhr";
              sha256 = "056a0b6a804ef03070f89b9b2e09d3271539654f4e2c30bb7d229730262f3fb8";
            };

            beamDeps = [
              text
            ];
          };
        in
        drv;

      text_diff =
        let
          version = "0.1.0";
          drv = buildMix {
            inherit version;
            name = "text_diff";
            appConfigPath = ./config;

            src = fetchHex {
              inherit version;
              pkg = "text_diff";
              sha256 = "d1ffaaecab338e49357b6daa82e435f877e0649041ace7755583a0ea3362dbd7";
            };
          };
        in
        drv;

      thousand_island =
        let
          version = "1.4.2";
          drv = buildMix {
            inherit version;
            name = "thousand_island";
            appConfigPath = ./config;

            src = fetchHex {
              inherit version;
              pkg = "thousand_island";
              sha256 = "1c7637f16558fc1c35746d5ee0e83b18b8e59e18d28affd1f2fa1645f8bc7473";
            };

            beamDeps = [
              telemetry
            ];
          };
        in
        drv;

      timex =
        let
          version = "3.7.13";
          drv = buildMix {
            inherit version;
            name = "timex";
            appConfigPath = ./config;

            src = fetchHex {
              inherit version;
              pkg = "timex";
              sha256 = "09588e0522669328e973b8b4fd8741246321b3f0d32735b589f78b136e6d4c54";
            };

            beamDeps = [
              combine
              gettext
              tzdata
            ];
          };
        in
        drv;

      tls_certificate_check =
        let
          version = "1.29.0";
          drv = buildRebar3 {
            inherit version;
            name = "tls_certificate_check";

            src = fetchHex {
              inherit version;
              pkg = "tls_certificate_check";
              sha256 = "5b0d0e5cb0f928bc4f210df667304ed91c5bff2a391ce6bdedfbfe70a8f096c5";
            };

            beamDeps = [
              ssl_verify_fun
            ];
          };
        in
        drv;

      towel =
        let
          version = "0.2.2";
          drv = buildMix {
            inherit version;
            name = "towel";
            appConfigPath = ./config;

            src = fetchHex {
              inherit version;
              pkg = "towel";
              sha256 = "a7b3d16a63f4ccdb66388f2cf61e6701bfc190e0f0afaefbf246c909263725c2";
            };
          };
        in
        drv;

      twinkle_star =
        let
          version = "0.1.0";
          drv = buildMix {
            inherit version;
            name = "twinkle_star";
            appConfigPath = ./config;

            src = pkgs.fetchFromGitHub {
              owner = "bonfire-networks";
              repo = "twinkle_star";
              rev = "476f464e38c5409438246ca15e42e44b527ca257";
              hash = "sha256-8IwnJkG3ML4v2yCCB8bo/0HpyA2EYKrbtnPg14aGuxY=";
            };

            beamDeps = [
              file_info
              ex_marcel
              hackney
            ];
          };
        in
        drv;

      typed_ecto_schema =
        let
          version = "0.4.3";
          drv = buildMix {
            inherit version;
            name = "typed_ecto_schema";
            appConfigPath = ./config;

            src = fetchHex {
              inherit version;
              pkg = "typed_ecto_schema";
              sha256 = "dcbd9b35b9fda5fa9258e0ae629a99cf4473bd7adfb85785d3f71dfe7a9b2bc0";
            };

            beamDeps = [
              ecto
            ];
          };
        in
        drv;

      tz_world =
        let
          version = "1.4.1";
          drv = buildMix {
            inherit version;
            name = "tz_world";
            appConfigPath = ./config;

            src = fetchHex {
              inherit version;
              pkg = "tz_world";
              sha256 = "9173ba7aa7c5e627e23adfc0c8d001a56a7072d5bdc8d3a94e4cd44e25decba1";
            };

            beamDeps = [
              castore
              certifi
              geo
              jason
            ];
          };
        in
        drv;

      tzdata =
        let
          version = "1.1.3";
          drv = buildMix {
            inherit version;
            name = "tzdata";
            appConfigPath = ./config;

            src = fetchHex {
              inherit version;
              pkg = "tzdata";
              sha256 = "d4ca85575a064d29d4e94253ee95912edfb165938743dbf002acdf0dcecb0c28";
            };

            beamDeps = [
              hackney
            ];
          };
        in
        drv;

      unfurl =
        let
          version = "0.6.2";
          drv = buildMix {
            inherit version;
            name = "unfurl";
            appConfigPath = ./config;

            src = pkgs.fetchFromGitHub {
              owner = "bonfire-networks";
              repo = "unfurl";
              rev = "30d8de8383ba3de71b796dc72aa80865d7ea5421";
              hash = "sha256-b70hkVUsa7WkzImGvCTdrDBZylQiHPPbC89yL1voTe0=";
            };

            beamDeps = [
              tesla
              hackney
              floki
              jason
              plug_cowboy
              arrows
              untangle
              faviconic
            ];
          };
        in
        drv;

      unicode_util_compat =
        let
          version = "0.7.1";
          drv = buildRebar3 {
            inherit version;
            name = "unicode_util_compat";

            src = fetchHex {
              inherit version;
              pkg = "unicode_util_compat";
              sha256 = "b3a917854ce3ae233619744ad1e0102e05673136776fb2fa76234f3e03b23642";
            };
          };
        in
        drv;

      uniq =
        let
          version = "0.6.1";
          drv = buildMix {
            inherit version;
            name = "uniq";
            appConfigPath = ./config;

            src = fetchHex {
              inherit version;
              pkg = "uniq";
              sha256 = "6426c34d677054b3056947125b22e0daafd10367b85f349e24ac60f44effb916";
            };

            beamDeps = [
              ecto
            ];
          };
        in
        drv;

      unsafe =
        let
          version = "1.0.2";
          drv = buildMix {
            inherit version;
            name = "unsafe";
            appConfigPath = ./config;

            src = fetchHex {
              inherit version;
              pkg = "unsafe";
              sha256 = "b485231683c3ab01a9cd44cb4a79f152c6f3bb87358439c6f68791b85c2df675";
            };
          };
        in
        drv;

      untangle =
        let
          version = "0.3.3";
          drv = buildMix {
            inherit version;
            name = "untangle";
            appConfigPath = ./config;

            src = pkgs.fetchFromGitHub {
              owner = "bonfire-networks";
              repo = "untangle";
              rev = "00c4aea4f8261bd9030a1585c60601b1a43cb5d9";
              hash = "sha256-RB3r3YOlHTzdylN+fwjnXpoOe/7QjKQ0sqHsEEPY/vk=";
            };

            beamDeps = [
              process_tree
              decorator
            ];
          };
        in
        drv;

      verbs =
        let
          version = "0.6.1";
          drv = buildMix {
            inherit version;
            name = "verbs";
            appConfigPath = ./config;

            src = pkgs.fetchFromGitHub {
              owner = "shannonwells";
              repo = "verbs_ex";
              rev = "afa4693964dae0d9aceb60a73f1766c6d4f68d25";
              hash = "sha256-6edAt/lw4MMny8UsPmqJMEu0zrpF+9Halx4QXTUN3Ik=";
            };
          };
        in
        drv;

      vix =
        let
          version = "0.35.0";
          drv = buildMix {
            inherit version;
            name = "vix";
            appConfigPath = ./config;

            VIX_COMPILATION_MODE = "PLATFORM_PROVIDED_LIBVIPS";

            nativeBuildInputs = with pkgs; [
              pkg-config
              vips
            ];

            src = fetchHex {
              inherit version;
              pkg = "vix";
              sha256 = "a3e80067a89d0631b6cf2b93594e03c1b303a2c7cddbbdd28040750d521984e5";
            };

            beamDeps = [
              cc_precompiler
              elixir_make
            ];
          };
        in
        drv.override (workarounds.elixirMake { } drv);

      voodoo =
        let
          version = "0.1.0";
          drv = buildMix {
            inherit version;
            name = "voodoo";
            appConfigPath = ./config;

            src = pkgs.fetchFromGitHub {
              owner = "bonfire-networks";
              repo = "voodoo";
              rev = "cc2d61300554edc52f933f10dcf77a046a5751e2";
              hash = "sha256-J7qNpbpz0oqq6DR2sXR9ecu9oBUM7gkk2+LsVFAuG3U=";
            };

            beamDeps = [
              untangle
            ];
          };
        in
        drv;

      waffle =
        let
          version = "1.1.9";
          drv = buildMix {
            inherit version;
            name = "waffle";
            appConfigPath = ./config;

            src = fetchHex {
              inherit version;
              pkg = "waffle";
              sha256 = "307c63cfdfb4624e7c423868a128ccfcb0e5291ae73a9deecb3a10b7a3eb277c";
            };

            beamDeps = [
              ex_aws
              ex_aws_s3
              hackney
              sweet_xml
            ];
          };
        in
        drv;

      want =
        let
          version = "1.18.0";
          drv = buildMix {
            inherit version;
            name = "want";
            appConfigPath = ./config;

            src = fetchHex {
              inherit version;
              pkg = "want";
              sha256 = "b9ac94ca249924f16f545ff6f128af53fa401349214f69788f360a3835bb9c9a";
            };
          };
        in
        drv;

      websock =
        let
          version = "0.5.3";
          drv = buildMix {
            inherit version;
            name = "websock";
            appConfigPath = ./config;

            src = fetchHex {
              inherit version;
              pkg = "websock";
              sha256 = "6105453d7fac22c712ad66fab1d45abdf049868f253cf719b625151460b8b453";
            };
          };
        in
        drv;

      websock_adapter =
        let
          version = "0.5.9";
          drv = buildMix {
            inherit version;
            name = "websock_adapter";
            appConfigPath = ./config;

            src = fetchHex {
              inherit version;
              pkg = "websock_adapter";
              sha256 = "5534d5c9adad3c18a0f58a9371220d75a803bf0b9a3d87e6fe072faaeed76a08";
            };

            beamDeps = [
              bandit
              plug
              plug_cowboy
              websock
            ];
          };
        in
        drv;

      zest =
        let
          version = "0.1.2";
          drv = buildMix {
            inherit version;
            name = "zest";
            appConfigPath = ./config;

            src = fetchHex {
              inherit version;
              pkg = "zest";
              sha256 = "ebe2d6acf615de286e45846a3d6daf72d7c20f2c5eefada6d8a1729256a3974a";
            };
          };
        in
        drv;

      zstream =
        let
          version = "0.6.7";
          drv = buildMix {
            inherit version;
            name = "zstream";
            appConfigPath = ./config;

            src = fetchHex {
              inherit version;
              pkg = "zstream";
              sha256 = "48c43ae0f00cfcda1ccb69c1d044755663d43b2ee8a0a65763648bf2078d634d";
            };
          };
        in
        drv;

    };
in
self
