{
  lib,
  writeTextDir,
  fetchFromGitHub,
  beam,
  callPackage,
  rustc,
  cargo,
  pkgs,
  _experimental-update-script-combinators,
  fetchpatch2,
  gitUpdater,
  ...
}:
let
  # Explanation: unstable version which includes fixes from:
  # https://github.com/bonfire-networks/bonfire-app/issues/1637
  version = "1.0.0-unstable-2025-11-17";
  src = fetchFromGitHub {
    owner = "bonfire-networks";
    repo = "bonfire-app";
    #tag = "v${version}";
    rev = "77994847bf500c700b570627564c77f11ff85de7";
    hash = "sha256-NpZp+vhdPwcbKjsmXCHiAJmub+673+soDEVTYOdcBfE=";
  };
  beamPkgs = beam.packagesWith beam.interpreters.erlang_28;
  # Explanation: reuse a modified bonfire-app's ./config when building each dependency.
  appConfigPath =
    src:
    pkgs.symlinkJoin {
      name = "bonfire-config";
      paths = [
        (writeTextDir "config.exs" ''
          import Config
          # Explanation: reimport overriden config.exs
          import_config("${src}/config/config.exs")

          # Explanation: set skip_compilation? to let nix provide Rust libraries,
          # and load_from because rustler defaults to priv/native/#{crate}
          # but deps_nix install into priv/native/lib#{crate}.
          #
          # Issue: https://github.com/code-supply/deps_nix/issues/36
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
        '')
        "${src}/config"
      ];
    };
  beamPackages = beamPkgs // {
    buildMix =
      previousArgs:
      beamPkgs.buildMix (
        lib.recursiveUpdate previousArgs {
          appConfigPath = appConfigPath src;
          # Explanation: config/bonfire_common.exs
          # uses this to set :rustler_precompiled, force_build_all
          # which is needed to let nix provision Rust libraries.
          env.RUSTLER_BUILD_ALL = "true";

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

          # Explanation: workaround the `cp -r ${appConfigPath} config` done by buildMix,
          # which preserves the u-w from the Nix store
          # and causes various mkdir failures for some dependencies
          # (surface_form_helpers, bonfire_ui_common, bonfire_editor_milkdown, …), eg:
          #
          # ** (File.Error) could not make directory (with -p) "/build/source/config/current_flavour/assets/hooks": no such file or directory
          postConfigure = previousArgs.postConfigure or "" + ''
            chmod u+w config
          '';
        }
      );
  };
  # Explanation: this ./deps.nix has been generated with https://github.com/code-supply/deps_nix
  # instead of https://github.com/ydlr/mix2nix which has no support for :git dependencies.
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
      lib.map (path: callPackage path { inherit beamPackages; }) [
        deps/bonfire_common.nix
        deps/bonfire_data_access_control.nix
        deps/bonfire_data_activity_pub.nix
        deps/bonfire_data_edges.nix
        deps/bonfire_federate_activitypub.nix
        deps/bonfire_ui_common.nix
        deps/bonfire_ui_me.nix
        deps/ember.nix
        deps/evision.nix
        deps/ex_cldr.nix
        deps/lazy_html.nix
        deps/social.nix
      ]
    );
  };
  depsUpdate = callPackage ./update.nix { };
in
beamPackages.mixRelease rec {
  pname = "bonfire";
  inherit src;
  inherit version mixNixDeps;
  inherit (beamPackages) erlang elixir;
  mixEnv = "prod";
  patches = [
    # Explanation: fix installing a `FLAVOUR` different than base_flavour (aka. ember),
    # eg. enable to install `FLAVOUR=social`.
    (fetchpatch2 {
      name = "fix-installing-flavour";
      url = "https://github.com/bonfire-networks/bonfire-app/pull/1652.patch";
      hash = "sha256-iasWT0/vJnRlZUaujXtLR7hftDXZL064+KXUOYa9CvQ=";
    })
  ];
  # Explanation: reuse the very same config/ as the one used to build dependencies.
  prePatch = ''
    rm -rf config
    cp --no-preserve=mode -r ${appConfigPath src} config
  '';
  # Explanation: workaround mismatch in module name.
  # Issue: https://github.com/bonfire-networks/bonfire-app/issues/1651#issuecomment-3554026240
  postPatch = ''
    chmod u+w config/
    rm config/runtime.exs
    substitute ${src}/config/runtime.exs config/runtime.exs \
      --replace-fail Bonfire.RuntimeConfig ${lib.toSentenceCase env.FLAVOUR}.RuntimeConfig
  '';

  env = {
    FLAVOUR = "social";
    WITH_IMAGE_VIX = "true";
    RUSTLER_BUILD_ALL = "true";
    WITH_GIT_DEPS = "1";
    WITH_FORKS = "0";
    # ToDo: support those?
    #WITH_XMPP = "1";
    #WITH_API_GRAPHQL = "1";
  };

  passthru = {
    inherit beamPackages mixNixDeps;
    depsNix = depsUpdate.package;
    # Usage: `update bonfire`
    updateScript = _experimental-update-script-combinators.sequence [
      (gitUpdater {
        rev-prefix = "v";
        ignoredVersions = ".*rc.*";
      })
      {
        command = [ (lib.getExe depsUpdate.script) ];
        # Explanation: required by nix-update:
        # > error: Combining update scripts with features enabled
        # > (other than “silent” scripts and an optional single script with “commit”)
        # > is currently unsupported.
        supportedFeatures = [ "silent" ];
      }
    ];
  };

  meta = {
    homepage = "https://github.com/bonfire-networks/bonfire-app";
    license = with lib.licenses; [
      agpl3Only
      cc0
    ];
    maintainers = with lib.maintainers; [ julm ];
  };
}
