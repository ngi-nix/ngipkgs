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
            --option sandbox false \
            --repair \
            --no-link --print-out-paths \
            .#bonfire.passthru.update.package)" \
          pkgs/by-name/bonfire/deps.nix
      ''
      (lib.concatMapStringsSep "\n" (
        name:
        # Explanation: nurl overrides the outputHash of the given derivation with a fake hash,
        # and calls `nix build` to print the correct one.
        lib.optionalString (bonfire.mixNixDeps.${name}.passthru ? "yarnOfflineCache") ''
          nurl --expr '(import ./. {}).bonfire.mixNixDeps.${name}.yarnOfflineCache' \
            >pkgs/by-name/bonfire/deps/${name}/yarnOfflineCache.hash
        ''
      ) (lib.attrNames bonfire.mixNixDeps))
    ];
  };

  package = bonfire.overrideAttrs (previousAttrs: {
    nativeBuildInputs = previousAttrs.nativeBuildInputs or [ ] ++ [
      cacert
      gnused
      nixfmt-rfc-style
    ];
    postPatch =
      previousAttrs.postPatch or ""
      + lib.concatStringsSep "\n" [
        # Explanation: inject deps_nix into bonfire's dependencies.
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
      mix deps.get --only prod
      mix deps.nix
      nixfmt deps.nix
    '';
    installPhase = ''
      cp -f deps.nix $out
    '';
  });
}
