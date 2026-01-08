{
  lib,
  cacert,
  gnused,
  nixfmt-rfc-style,
  deps_nix_injection_pattern,
  package,
  ...
}:
package.overrideAttrs (
  finalAttrs: previousAttrs: {
    pname = "${previousAttrs.pname}-update";

    passthru = previousAttrs.passthru or { } // {
      # Explanation: dependencies are what is being updated,
      # hence remove (using // instead of lib.recursiveUpdate)
      # any previous dependencies to not require them to be built.
      mixNixDeps = { };
    };

    # Explanation: this is an update script that needs access to the net
    # without knowing hashes yet because it's precisely its job to set them.
    __noChroot = true;

    nativeBuildInputs = previousAttrs.nativeBuildInputs or [ ] ++ [
      cacert
      gnused
      nixfmt-rfc-style
    ];
    env = previousAttrs.env or { } // {
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
            --replace-fail '${deps_nix_injection_pattern}' \
                           '${deps_nix_injection_pattern} [{ :deps_nix, git: "https://github.com/code-supply/deps_nix" }] ++'
        ''
        # Explanation: re-enable downloading of well-known precompiled Rust libs.
        ''
          mkdir -p config
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
      ];
    configurePhase = lib.concatStringsSep "\n" [
      ''
        runHook preConfigure
      ''
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
      ''
        runHook postConfigure
      ''
    ];
    buildPhase = ''
      mix local.hex --force --if-missing
      mix local.rebar --force --if-missing
      mix deps.get --only ${finalAttrs.mixEnv}
      mix deps.nix --env ${finalAttrs.mixEnv}
      nixfmt deps.nix
    '';
    installPhase = ''
      cp -f deps.nix $out
    '';
  }
)
