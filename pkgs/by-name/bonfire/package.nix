{
  lib,
  fetchFromGitHub,
  beam,
  callPackage,
  rustc,
  cargo,
  pkgs,
  _experimental-update-script-combinators,
  fetchpatch2,
  gitUpdater,
  nodejs,
  yarnConfigHook,
  ...
}:
let
  # Explanation: unstable version which includes fixes from:
  # https://github.com/bonfire-networks/bonfire-app/issues/1637
  version = "1.0.0-unstable-2025-11-17";
  flavour = "social";
  src = fetchFromGitHub {
    owner = "bonfire-networks";
    repo = "bonfire-app";
    #tag = "v${version}";
    rev = "77994847bf500c700b570627564c77f11ff85de7";
    hash = "sha256-NpZp+vhdPwcbKjsmXCHiAJmub+673+soDEVTYOdcBfE=";
  };

  beamPkgs = beam.packagesWith beam.interpreters.erlang_28;

  # Explanation: to build its Erlang config (config/)
  # and some JavaScript imports (**/deps.hooks.js)
  # bonfire-app overlays symlinks from bonfire-app, ember and ${flavour}.
  bonfireSetup =
    let
      # Explanation: only used to get the `src`s, but without `beamPackages`
      # to avoid an infinite recursion.
      # Warning: this require deps.nix to already have those `src`s.
      deps = import ./deps.nix {
        inherit lib pkgs;
        beamPackages = beamPkgs;
      };
    in
    pkgs.runCommandLocal "bonfire-setup"
      {
        inherit src;
        nativeBuildInputs = [
          pkgs.just
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
          ''
            mkdir extensions
            cp --no-preserve=mode -r ${deps.ember.src} extensions/ember
            if [ ${flavour} != ember ]; then
              cp --no-preserve=mode -r ${deps.${flavour}.src} extensions/${flavour}
            fi
            cp --no-preserve=mode -r ${src}/config .
            cp --no-preserve=mode -rs ${src}/justfile .
            just flavour_make_symlinks ${flavour}
          ''

          # Explanation: from: just _flavour_install
          ''
            $SHELL extensions/${flavour}/install.sh --yes
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

            config :autumn,
                   Autumn.Native,
                   skip_compilation?: true,
                   load_from: {:autumn, "priv/native/libautumnus_nif"}
            config :mdex,
                   MDEx.Native,
                   skip_compilation?: true,
                   load_from: {:mdex, "priv/native/libcomrak_nif"}
            config :mjml,
                   Mjml.Native,
                   skip_compilation?: true,
                   load_from: {:mjml, "priv/native/libmjml_nif"}
            EOF
          ''
        ]
      );

  env = {
    FLAVOUR = flavour;
    # Explanation: config/bonfire_common.exs
    # uses this to set :rustler_precompiled, force_build_all
    # which is needed to let nix provision Rust libraries.
    RUSTLER_BUILD_ALL = "true";
  };

  beamPackages = beamPkgs // {
    buildMix =
      previousArgs:
      beamPkgs.buildMix (
        lib.recursiveUpdate previousArgs {
          # Explanation: Mix.Tasks.Compile.Surface.AssetGenerator.get_colocated_js_files(components)
          # uses module_info/1 to get the `source:`
          # of the components and derive the .hooks.js files to generate.
          # But by default buildMix enables ERL_COMPILER_OPTIONS=[deterministic]:
          # > deterministic
          # >     Omit the options and source tuples in the list
          # >     returned by Module:module_info(compile).
          # >     This option will make it easier to achieve reproducible builds.
          # Source: https://www.erlang.org/docs/20/man/compile.html
          #
          # For instance, with deterministic:
          # $ iex --erl "-kernel shell_history enabled" -S mix compile --no-deps-check
          # iex(1)> Bonfire.UI.Me.Stickyheader.module_info() |> get_in([:compile])
          # [version: ~c"9.0.2"]
          #
          # Whereas without deterministic:
          # $ iex --erl "-kernel shell_history enabled" -S mix compile --no-deps-check
          # iex(1)> Bonfire.UI.Me.Stickyheader.module_info() |> get_in([:compile])
          # [
          #   version: ~c"9.0.2",
          #   options: [:no_spawn_compiler_process, :from_core, :no_core_prepare,
          #    :no_auto_import],
          #   source: ~c"/build/source/lib/components/profile/stickyheader.ex"
          # ]
          #
          # That source path is deterministic, within the nix sandbox of the current package.
          # The options likely too.
          # So disabling deterministic should not impact reproducibility.
          #
          # Issue: https://github.com/surface-ui/surface/issues/762
          # FixMe(maint/simplicity): revert back to true once the above issue has been fixed.
          erlangDeterministicBuilds = false;

          # Explanation: sadly disabling erlangDeterministicBuilds is not enough
          # for `mix compile.surface` to work accross packages, as it:
          # - needs to access the content of the source path of the dependencies,
          # - and, uses as source path the actual path used where the dependencies were built.
          # Since buildMix's installPhase only copies $src into $out/src,
          # that is not enough: module_info/1 will return /build/source instead of $out/src,
          # so build into $out/src, which will remain reachable after the build.
          # Issue: https://github.com/surface-ui/surface/issues/762#issuecomment-3577030748
          postUnpack = previousArgs.postUnpack or "" + ''
            mkdir -p $out
            mv $sourceRoot $out/src
            sourceRoot=$out/src
            src=$(mktemp -d)
          '';
          postInstall = previousArgs.postInstall or "" + ''
            src=$out/src
            rm -rf _build
          '';

          # Explanation: in some of its own dependencies,
          # bonfire uses Mess for managing dependencies,
          # which requires to vendor-in mess.exs,
          # but as of Bonfire 1.0.0 some are outdated wrt. bonfire-app/lib/mix/mess.exs
          # causing mix to fail hard… so, override globally without remorse.
          postPatch = ''
            if grep -qF Mess mix.exs; then
              ln -fns \${src + "/lib/mix/mess.exs"} mess.exs
              # Explanation: some mix.exs depend on mess.exs but do not load it…
              sed -i mix.exs -e 's/^ *# *Code.eval_file(\"mess.exs\"/Code.eval_file(\"mess.exs\"/'
            fi
          ''
          + previousArgs.postPatch or "";

          # Explanation: get a writable extensions.
          # Because some dependencies generate files into them,
          # eg. surface_form_helpers generates into config/current_flavour/assets/hooks/
          # which points to extensions/social/assets/hooks/
          appConfigPath = "${bonfireSetup}/config";
          inherit env;
          postConfigure = ''
            cp --no-preserve=mode -r ${bonfireSetup}/extensions .
          '';
        }
      );
  };
  # Explanation: this ./deps.nix is generated with https://github.com/code-supply/deps_nix
  # instead of https://github.com/ydlr/mix2nix which has no support for :git dependencies.
  # See: ./update.nix
  mixNixDeps = import ./deps.nix {
    inherit lib pkgs beamPackages;
    overrideFenixOverlay = finalPkgs: previousPkgs: {
      # Explanation: deps_nix generates a ./deps.nix
      # assuming fenix is used to provide rustToolchain,
      # but so far the rustc and cargo from nixpkgs are enough,
      # and more likely already in one's Nix store.
      fenix = {
        stable = {
          inherit rustc cargo;
        };
      };
    };
    overrides = lib.composeManyExtensions (
      lib.map (path: callPackage path { inherit beamPackages flavour bonfireSetup; }) [
        deps/bonfire_common.nix
        deps/bonfire_data_access_control.nix
        deps/bonfire_data_activity_pub.nix
        deps/bonfire_data_edges.nix
        deps/bonfire_editor_milkdown.nix
        deps/bonfire_federate_activitypub.nix
        deps/bonfire_geolocate.nix
        deps/bonfire_ui_common.nix
        deps/bonfire_ui_me.nix
        deps/ember.nix
        deps/evision.nix
        deps/ex_cldr.nix
        deps/iconify_ex.nix
        deps/lazy_html.nix
        deps/social.nix
      ]
    );
  };

  update = callPackage ./update.nix { };
in
beamPackages.mixRelease {
  pname = "bonfire";
  inherit src;
  inherit version;
  inherit (beamPackages) erlang elixir;
  inherit mixNixDeps;
  mixEnv = "prod";
  erlangDeterministicBuilds = false;

  nativeBuildInputs = [
    yarnConfigHook
    nodejs
  ];

  patches = [
    # Explanation: fix installing a `FLAVOUR` different than base_flavour (aka. ember),
    # eg. enable to install `FLAVOUR=social`.
    (fetchpatch2 {
      name = "fix-installing-flavour";
      url = "https://github.com/bonfire-networks/bonfire-app/pull/1652.patch";
      hash = "sha256-iasWT0/vJnRlZUaujXtLR7hftDXZL064+KXUOYa9CvQ=";
    })
  ];

  # Explanation: to run yarnConfigHook multiple times manually.
  dontYarnInstallDeps = true;

  # Explanation: reuse almost the same bonfireSetup as the one used to build dependencies.
  postConfigure = lib.concatStringsSep "\n" [
    # Explanation: bonfire_ui_common & co. look like Elixir libraries,
    # but can only be built correctly inside bonfire-app.
    ''
      cp --no-preserve=mode -r ${bonfireSetup}/* .
    ''
    # Explanation: same is true for their yarn assets.
    (lib.concatMapStringsSep "\n"
      (name: ''
        rm -rf deps/${name}
        cp --no-preserve=mode -r \
           ${mixNixDeps.${name}.src} \
           deps/${name}
        pushd deps/${name}/assets
        yarnOfflineCache="${mixNixDeps.${name}.yarnOfflineCache}" \
        yarnConfigHook
        popd
      '')
      (
        lib.attrNames (
          lib.filterAttrs (name: _value: mixNixDeps.${name}.passthru ? "yarnOfflineCache") mixNixDeps
        )
      )
    )
    ''
      mkdir -p extensions
      ln -s extensions/bonfire_ui_common/assets assets
      ln -s ../deps/bonfire_ui_common \
         extensions/bonfire_ui_common
    ''

    # Explanation: tzdata needs a writable directory to autoupdate
    # its TimeZone data periodically.
    ''
      cat >>config/runtime.exs <<EOF

        config :tzdata, :data_dir, System.get_env("TZDATA_DIR", "/var/lib/bonfire/tzdata")
      EOF
    ''

    # FixMe(functional/completeness): workaround :mime having a different value set for key :extensions
    # during runtime compared to compile time,
    # somehow runtime is missing bzip2, jetpack, 7z, gz, rar, swiftui, and styles
    #
    # Maybe related to this warning during configurePhase:
    # > Basic compile-time config prepared
    # > warning: redefining module Bonfire.Files.MimeTypes (current version loaded from /nix/store/wwjw1zdmdiqvscj5r3bm55aqjv80f2mx-bonfire_files-0.1.0/lib/erlang/lib/bonfire_files-0.1.0/ebin/Elixir.Bonfire.Files.MimeTypes.beam)
    ''
      substituteInPlace mix.exs \
        --replace-fail "runtime_config_path:" "validate_compile_env: false, runtime_config_path:"
    ''

    # See: justfile#_deps-post-get
    ''
      mkdir -p data
      mkdir -p data/uploads
      mkdir -p priv/static/data
      (cd priv/static/data && ln -fns ../../../data/uploads)
    ''
  ];
  preBuild = lib.concatStringsSep "\n" [
    ''
      mix do loadconfig, deps.loadpaths --no-deps-check, compile
    ''
    # Explanation: call lib/mix/tasks/sync_themes.ex
    # See: justfile#_flavour_install ${flavour}
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
      rm -rf ./priv/repo/*
      mkdir -p priv/repo/migrations/
      for file in deps/bonfire_*/priv/repo/migrations/*; do
        cp -ft priv/repo/migrations/ "$file"
      done
    ''
  ];

  postBuild = lib.concatStringsSep "\n" [
    # See: justfile#_rel-compile-assets
    ''
      pushd assets
      yarn --offline build
      popd
      mix phx.digest --no-deps-check
    ''
  ];

  # Explanation: only concern buildtime debugging,
  # by being more verbose about what mixRelease
  # and mix do (through MIX_DEBUG=1).
  enableDebugInfo = true;

  env = env // {
    WITH_IMAGE_VIX = "true";
    WITH_GIT_DEPS = "1";
    WITH_FORKS = "0";
    WITH_DOCKER = "no";
    # Explanation: from justfile's _ext-migrations-copy
    MIX_OS_DEPS_COMPILE_PARTITION_COUNT = "1";
    # ToDo(functional/completeness): support those?
    #WITH_XMPP = "1";
    #WITH_API_GRAPHQL = "1";
  };

  passthru = {
    inherit
      beamPackages
      mixNixDeps
      bonfireSetup
      update
      ;
    # HowTo(maint/update): `update bonfire`, or a bit faster:
    # nix -L develop --impure --expr 'import <nixpkgs/maintainers/scripts/update.nix> { \
    #     include-overlays = [ (final: prev: { inherit (import ./. {}) ngipkgs; }) ]; \
    #     package = "ngipkgs.bonfire"; \
    #   }'
    #
    # Warning(maint/update): bonfire having a huge dependency closure,
    # expect a lot of downloads during several minutes.
    updateScript = _experimental-update-script-combinators.sequence [
      (gitUpdater {
        rev-prefix = "v";
        ignoredVersions = ".*rc.*";
      })
      {
        command = [ (lib.getExe update.script) ];
        # Explanation: required by nix-update:
        # > error: Combining update scripts with features enabled
        # > (other than “silent” scripts and an optional single script with “commit”)
        # > is currently unsupported.
        supportedFeatures = [ "silent" ];
      }
    ];
  };

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
}
