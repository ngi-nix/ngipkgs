{#Contributor_Why_to_develop_a_package_using_Elixir_and_Surface_requires_a_hack}
# Why to develop a package using Elixir and Surface requires a hack?

`Mix.Tasks.Compile.Surface.AssetGenerator.get_colocated_js_files(components)`
uses `module_info/1` to:
- get the `source:` of the components,
- and derive the `*.hooks.js` files to generate.

But by default `buildMix` enables `ERL_COMPILER_OPTIONS=[deterministic]`:
> [deterministic](https://www.erlang.org/docs/20/man/compile.html):
>     Omit the options and source tuples in the list
>     returned by Module:module_info(compile).
>     This option will make it easier to achieve reproducible builds.

For instance, with `deterministic`:
```bash
$ iex --erl "-kernel shell_history enabled" -S mix compile --no-deps-check
iex(1)> Bonfire.UI.Me.Stickyheader.module_info() |> get_in([:compile])
[version: ~c"9.0.2"]
```

Whereas without `deterministic`:
```bash
$ iex --erl "-kernel shell_history enabled" -S mix compile --no-deps-check
iex(1)> Bonfire.UI.Me.Stickyheader.module_info() |> get_in([:compile])
[
  version: ~c"9.0.2",
  options: [:no_spawn_compiler_process, :from_core, :no_core_prepare,
   :no_auto_import],
  source: ~c"/build/source/lib/components/profile/stickyheader.ex"
]
```

That source path is deterministic, within the nix sandbox of the current package.
The options likely too.
So disabling `deterministic` should not impact reproducibility.

Issue: <https://github.com/surface-ui/surface/issues/762>

But for `mix compile.surface` to work accross packages
disabling `erlangDeterministicBuilds` is not enough, as it:
- needs to access the content of the source path of the dependencies,
- and, uses as source path the actual path used where the dependencies were built.
Since `buildMix`'s `installPhase` only copies `$src` into `$out/src`,
without actually building into `$out/src`, that is not enough:
`module_info/1` will return `/build/source` instead of `$out/src`,
so the hack is to build into `$out/src`, which will remain reachable after the build
by the packages depending on it.

Issue: https://github.com/surface-ui/surface/issues/762#issuecomment-3577030748
