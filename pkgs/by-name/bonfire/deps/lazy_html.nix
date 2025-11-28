{ lexbor, ... }:
finalMixPkgs: previousMixPkgs: {
  # Relevant: https://github.com/code-supply/deps_nix/pull/33
  lazy_html = previousMixPkgs.lazy_html.overrideAttrs (previousAttrs: {
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
    preConfigure = previousAttrs.preConfigure or "" + ''
      export ELIXIR_MAKE_CACHE_DIR="$TMPDIR/.cache"
    '';

    # Explanation: nix provides lexbor.
    preBuild = previousAttrs.preBuild or "" + ''
      export LEXBOR_GIT_SHA=
      install -Dm644 \
        -t _build/c/third_party/lexbor/$LEXBOR_GIT_SHA/build \
        ${lexbor}/lib/liblexbor_static.a
    '';
    buildInputs = previousAttrs.buildInputs or [ ] ++ [
      lexbor
    ];
  });
}
