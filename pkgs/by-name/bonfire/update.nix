{
  bonfire,
  cacert,
  coreutils,
  gnused,
  lib,
  nix,
  nurl,
  nixfmt-rfc-style,
  writeShellApplication,
  writeTextDir,
}:

{
  script = writeShellApplication {
    name = "bonfire-update";
    runtimeInputs = [
      coreutils
      nix
      nurl
    ];
    # Explanation: ./deps.nix has to preexist (even if just `_: {}`)
    # because mixRelease uses an assert forcing its existence,
    # but its impact on ERL_LIBS and deps/ is correctly unset before `mix deps.get`.
    text = lib.concatStringsSep "\n" [
      ''
        cp -f "$(
          nix -L --extra-experimental-features "nix-command flakes" \
            build \
            --option sandbox relaxed \
            --repair \
            --no-link --print-out-paths \
            .#bonfire.passthru.update.package \
          )" \
          pkgs/by-name/bonfire/deps.nix
      ''
      (lib.concatMapStringsSep "\n" (
        name:
        lib.optionalString (bonfire.mixNixDeps.${name}.passthru ? "yarnOfflineCache") ''
          nurl --expr '(import ./. {}).bonfire.mixNixDeps.${name}.yarnOfflineCache' \
            >pkgs/by-name/bonfire/deps/${name}/yarnOfflineCache.hash
        ''
      ) (lib.attrNames bonfire.mixNixDeps))
      ''
        nurl --expr '(import ./. {}).bonfire.mixNixDeps.ex_cldr.src' \
          >pkgs/by-name/bonfire/deps/ex_cldr/hash
      ''
    ];
  };

  package =
    # Explanation: as of nixos-25.11, mixRelease is not yet using
    # lib.extendMkDerivation to provide finalAttrs,
    # so it's not possible to empty mixNixDeps
    # to avoid building the previous dependencies when updating.
    # Hence call a new mixRelease, using `inherit` instead of `override`.
    #
    # Warning: this has the drawback of being sure to inherit
    # everything here that is needed, especially postConfigure.
    (bonfire.passthru.beamPackages.mixRelease ({
      pname = "bonfire-update";
      mixNixDeps = { };
      inherit (bonfire)
        elixir
        enableDebugInfo
        env
        erlang
        erlangDeterministicBuilds
        mixEnv
        patches
        postConfigure
        src
        version
        ;
    })).overrideAttrs
      (previousAttrs: {
        # Explanation: this is an update script that needs access to the net
        # without knowing hashes yet because it's precisely its job to set them.
        __noChroot = true;

        nativeBuildInputs = previousAttrs.nativeBuildInputs or [ ] ++ [
          cacert
          gnused
          nixfmt-rfc-style
        ];
        env = previousAttrs.env // {
          # Explanation: relax limits to avoid error:
          # > Request failed (:timeout)
          HEX_HTTP_CONCURRENCY = 1;
          HEX_HTTP_TIMEOUT = 120;
        };
        postPatch =
          previousAttrs.postPatch or ""
          + lib.concatStringsSep "\n" [
            # Applies: manuals/Contributor/Why_to/develop/a_package/using_Elixir/with_deps_nix.md
            ''
              substituteInPlace mix.exs \
                --replace-fail 'extra_deps =' \
                               'extra_deps = [{ :deps_nix, git: "https://github.com/code-supply/deps_nix" }] ++'
            ''
            # Explanation: re-enable downloading of precompiled Rust libs.
            ''
              cat >>config/config.exs <<EOF
              config :autumn,
                     Autumn.Native,
                     skip_compilation?: true
              config :mdex,
                     MDEx.Native,
                     skip_compilation?: true
              config :mjml,
                     Mjml.Native,
                     skip_compilation?: true
              EOF
            ''
            # Explanation: re-enable downloading of precompiled Rust libs.
            ''
              cat >>config/config.exs <<EOF
              config :bonfire_common, Bonfire.Common.Localise.Cldr,
                force_locale_download: false
              EOF
            ''
          ];
        configurePhase = lib.concatStringsSep "\n" [
          # Explanation: let mix select and download all dependencies.
          ''
            unset ERL_LIBS
            unset HEX_OFFLINE
          ''
          # Explanation: prefer to download NIF
          ''
            unset RUSTLER_PRECOMPILED_FORCE_BUILD_ALL
            export HOME=$NIX_BUILD_TOP/home
            export GIT_SSL_CAINFO=$NIX_SSL_CERT_FILE
            export SSL_CERT_FILE=$NIX_SSL_CERT_FILE
          ''
        ];
        buildPhase = ''
          mix local.hex --force --if-missing
          mix local.rebar --force --if-missing
          mix deps.get --only ${bonfire.mixEnv}
          mix deps.nix --env ${bonfire.mixEnv}
          nixfmt deps.nix
        '';
        installPhase = ''
          cp -f deps.nix $out
        '';
      });
}
