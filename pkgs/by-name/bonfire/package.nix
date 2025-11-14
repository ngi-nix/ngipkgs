{
  lib,
  writeTextDir,
  fetchFromGitHub,
  beam,
  callPackage,
  rustc,
  cargo,
  pkgs,
}:
let
  version = "1.0.0";
  src = fetchFromGitHub {
    owner = "bonfire-networks";
    repo = "bonfire-app";
    tag = "v${version}";
    hash = "sha256-fkxeoDcIcq93ZacOqM5aUK9QHVXoZUCah6BdV9v/Alg=";
  };
  beamPkgs = beam.packagesWith beam.interpreters.erlang_28;
  beamPackages = beamPkgs // {
    buildMix =
      previousArgs:
      lib.makeOverridable beamPkgs.buildMix (
        lib.recursiveUpdate previousArgs {
          # Explanation: reuse a modified bonfire-app's ./config when building each dependency.
          appConfigPath = pkgs.symlinkJoin {
            name = "bonfire-config";
            paths = [
              (writeTextDir "config.exs" ''
                import Config
                # Explanation: reimport overriden config.exs
                Code.eval_file("${src}/config/config.exs")

                # Explanation: set skip_compilation? to let nix provide Rust libraries,
                # and load_from because rustler defaults to priv/native/#{crate}
                # but deps_nix install into priv/native/lib#{crate}.
                #
                # Issue: https://github.com/code-supply/deps_nix/issues/36
                config :mjml,
                       Mjml.Native,
                       skip_compilation?: true,
                       load_from: {:mjml, "priv/native/libmjml_nif"}
                config :mdex,
                       MDEx.Native,
                       skip_compilation?: true,
                       load_from: {:mdex, "priv/native/libcomrak_nif"}
                config :autumn,
                       Autumn.Native,
                       skip_compilation?: true,
                       load_from: {:autumn, "priv/native/libautumnus_nif"}
              '')
              "${src}/config"
            ];
          };
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

          # Explanation: workaround the `cp -r ${appConfigPath} config` done by deps_nix,
          # which preserves the u-w from the Nix store
          # and causes various mkdir failures for some dependencies
          # (surface_form_helpers, bonfire_ui_common, bonfire_editor_milkdown, …), eg:
          #
          # ** (File.Error) could not make directory (with -p) "/build/source/config/current_flavour/assets/hooks": no such file or directory
          postConfigure = previousArgs.postConfigure or "" + ''
            chmod u+w config
          '';

          # Explanation: a side effect of Bonfire using :git repositories
          # is that deps_nix currently does not extract the version field
          # from mix.exs and set the version to the Git revision.
          # Unfortunately this breaks the application at startup time,
          # so set version as expected by mix (using some heuristics).
          #
          # Issue: https://github.com/code-supply/deps_nix/issues/35
          version =
            let
              mix_exs = lib.readFile "${previousArgs.src}/mix.exs";
              dir = builtins.readDir previousArgs.src;
              # Exemple: version: "0.2.1"
              match_version_colon = lib.match ".*version: *['\"]([^'\"]*)['\"],.*" mix_exs;
            in
            if !(lib.match "[a-f0-9]{40}" previousArgs.version != null) then
              # version is not a revision, reuse it
              previousArgs.version
            else if lib.hasAttr "VERSION" dir then
              # version is in ./VERSION
              lib.readFile "${previousArgs.src}/VERSION"
            else if match_version_colon != null then
              # version is in version:
              lib.elemAt match_version_colon 0
            else
              # version is in @version
              lib.elemAt (lib.match ".*@version *['\"]([^'\"]*)['\"].*" mix_exs) 0;
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
        # Explanation(-security/confidentiality):
        # appsignal uses a closed-source agent to collect data.
        # Issue: https://github.com/bonfire-networks/bonfire-app/issues/1637
        #deps/appsignal.nix
        deps/bonfire_common.nix
        deps/bonfire_data_access_control.nix
        deps/bonfire_data_activity_pub.nix
        deps/bonfire_data_edges.nix
        deps/bonfire_ui_me.nix
        deps/bonfire_federate_activitypub.nix
        deps/bonfire_ui_common.nix
        deps/ex_cldr.nix
        deps/lazy_html.nix
        # ToDo(portability/install): used when env.WITH_IMAGE_VIX = "true"
        # but this will require to regenerate ./deps.nix with deps_nix
        #deps/evision.nix
      ]
    );
  };
in

# Explanation: as of nixos-25.11, mixRelease is not yet compatible with
# lib.extendMkDerivation to provide finalAttrs,
# hence use « let » above for mutual definitions.
beamPackages.mixRelease {
  pname = "bonfire";
  inherit version src mixNixDeps;
  inherit (beamPackages) erlang elixir;
  enableDebugInfo = true;
  mixEnv = "prod";
  env.FLAVOUR = "social";
  passthru = {
    inherit beamPackages mixNixDeps;
  };
}
