{#Contributor_Why_to_develop_a_package_using_Elixir_with_deps_nix}
# Why to develop a package using Elixir?

{#Contributor_Why_to_develop_a_package_using_Elixir_with_deps_nix_Pros}
## Pros
- Like `mix2nix`, `deps_nix` enables to use separate Nix derivations for each dependency
instead of using a big Fixed-Output Derivation.
This enables to cache compiled dependencies and to reuse them when they don't change.
- While `mix2nix` is a function of a `mix.lock`,
[`deps_nix`](https://github.com/code-supply/deps_nix) instead uses Mix's internals
to allow you to choose packages from certain environments.
- Contrary to `mix2nix`, `deps_nix` supports `:git` and `:path` dependencies.
- Contrary to `mix2nix`, `deps_nix` has a builtin support for dependencies
using `rustler-precompiled` that works most of the time without additional overriding.

{#Contributor_Why_to_develop_a_package_using_Elixir_with_deps_nix_Cons}
## Cons
- By default the builting support for `rustler-precompiled` depends on
  the Rust toolchain provisionned by [fenix](https://github.com/nix-community/fenix)
  but the `pkgs.rustc` and `pkgs.cargo` provisionned by Nixpkgs
  (hence more likely already on users' Nix store)
  can be used instead with an `overrideFenixOverlay`.
- The builting support for `rustler-precompiled` depends on `allow-import-from-derivation=true`,
  which is not allowed in Nixpkgs nor NGIpkgs.
- `deps_nix` is young.
