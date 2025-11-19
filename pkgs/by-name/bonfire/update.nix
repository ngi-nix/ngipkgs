{
  bonfire,
  cacert,
  coreutils,
  gnused,
  nix,
  symlinkJoin,
  writeShellApplication,
  writeTextDir,
}:

rec {
  script = writeShellApplication {
    name = "bonfire-update";
    runtimeInputs = [
      coreutils
      nix
    ];
    # Explanation: ./deps.nix has to preexist (even if just `_: {}`)
    # because mixRelease uses an assert forcing its existence,
    # but its impact on ERL_LIBS is correctly unset before `mix deps.get`.
    text = ''
      nix -L build --option sandbox false --repair .#bonfire.passthru.depsNix
      cp -f result pkgs/by-name/bonfire/deps.nix
      rm -f result
    '';
  };

  config = symlinkJoin {
    name = "bonfire-config";
    paths = [
      # Explanation: enable downloading of precompiled Rust libs.
      (writeTextDir "config.exs" ''
        import Config
        # Explanation: reimport overriden config.exs
        import_config("${bonfire.src}/config/config.exs")

        config :autumn,
               Autumn.Native,
               skip_compilation?: true
        config :mdex,
               MDEx.Native,
               skip_compilation?: true
        config :mjml,
               Mjml.Native,
               skip_compilation?: true
      '')
      "${bonfire.src}/config"
    ];
  };

  package = bonfire.overrideAttrs (previousAttrs: {
    nativeBuildInputs = previousAttrs.nativeBuildInputs or [ ] ++ [
      cacert
      gnused
    ];
    postPatch = previousAttrs.postPatch or "" + ''
      # Explanation: inject deps_nix into bonfire's dependencies.
      substituteInPlace mix.exs \
        --replace-fail 'extra_deps =' \
                       'extra_deps = [{ :deps_nix, git: "https://github.com/code-supply/deps_nix" }] ++'

      rm -rf config
      cp --no-preserve=mode -r ${config} config
    '';
    configurePhase = ''
      # Explanation: let mix select and download all dependencies.
      unset ERL_LIBS
      unset HEX_OFFLINE
      # Explanation: prefer to download NIF
      unset RUSTLER_PRECOMPILED_FORCE_BUILD_ALL
      export HOME=$NIX_BUILD_TOP/home
      export GIT_SSL_CAINFO=$NIX_SSL_CERT_FILE
      export SSL_CERT_FILE=$NIX_SSL_CERT_FILE
    '';
    buildPhase = ''
      mix local.hex --force --if-missing
      mix local.rebar --force --if-missing
      mix deps.get
      mix deps.nix
    '';
    installPhase = ''
      cp -f deps.nix $out
    '';
  });
}
