{#Contributor_How_to_develop_a_package_using_Elixir}
# How to develop a package using Elixir?

BEAM build helper  builds into `$out/src` instead of `/build/source`
so `cd $NIX_BUILD_TOP` after `nix develop` will not build in `$NIX_BUILD_TOP`,
instead switch to a temporary directory before `nix develop`:

```console
$ nix -L develop -f. bonfire.ember
[path/to/NGIpkgs]$ cd $NIX_BUILD_TOP
[/tmp/nix-shell.11yuxY]$ runPhase unpackPhase
[/tmp/nix-shell.11yuxY/source]$ runPhase patchPhase
[/tmp/nix-shell.11yuxY/source]$ runPhase configurePhase
[/tmp/nix-shell.11yuxY/source]$ runPhase buildPhase
```

When investigating a bug, you may want to run Elixir code
in the interactive prompt:
```console
$ iex --erl "-kernel shell_history enabled" -S mix compile --no-deps-check
```

When investigating a bug, you may want to edit a dependency,
do that un `deps/$dep` while not forgetting to remove `_build/$MIX_ENV/lib/$dep`:
```console
$ nix -L develop -f. bonfire.ember
[path/to/NGIpkgs]$ cd $NIX_BUILD_TOP
[/tmp/nix-shell.11yuxY]$ runPhase unpackPhase
[/tmp/nix-shell.11yuxY/source]$ runPhase patchPhase
[/tmp/nix-shell.11yuxY/source]$ runPhase configurePhase
[/tmp/nix-shell.11yuxY/source]$ dep=bonfire_api_graphql
[/tmp/nix-shell.11yuxY/source]$ orig=$(realpath deps/$dep)
[/tmp/nix-shell.11yuxY/source]$ rm deps/$dep _build/$MIX_ENV/lib/$dep
[/tmp/nix-shell.11yuxY/source]$ cp -ar --no-preserve=mode $orig deps/$dep
[/tmp/nix-shell.11yuxY/source]$ (cd deps/$dep; git init; git add .; git commit -m init)
[/tmp/nix-shell.11yuxY/source]$ $EDITOR deps/$dep/
[/tmp/nix-shell.11yuxY/source]$ runPhase buildPhase
```

```{toctree}
using_Elixir/and_Surface.md
using_Elixir/with_deps_nix.md
```
