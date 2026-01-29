{#Contributor_How_to_develop_a_package_using_Elixir_with_deps_nix}
# How to develop a package using Elixir with deps_nix?

`deps_nix` must be injected into the `deps` of the `mix.exs`,
to get something looking like:
```elixir
def deps do
  [ { :deps_nix, git: "https://github.com/code-supply/deps_nix" } ] ++
  existing_deps
end
```
This could be done in `postPatch` using `substituteInPlace mix.exs --replace-fail`.

`deps.nix` can then be generated with something like:
```bash
mix local.hex --force --if-missing
mix local.rebar --force --if-missing
mix deps.get --only prod
mix deps.nix --env prod
nixfmt deps.nix
```

:::{warning}
You may have to drop `--only prod`
if Upstream is not testing `prod`.
:::

:::{warning}
Be careful that `mix deps.get` is regenerating `mix.lock` from `mix.exs`
and if there are inconsistencies between `mix.exs` and `mix.lock`
it may pin different versions than the one in upstream's `mix.lock`.
Which [did cause a problem in the past](https://github.com/bonfire-networks/bonfire-app/issues/1670#issuecomment-3649953300).
:::

The resulting `deps.nix` can then be tracked by the version control software
and used like this, reusing `rustc` and `cargo` from `pkgs`,
instead of using the one provisioned by `fenix`:

```nix
{ beamPackages, cargo, rustc, lib, pkgs }:
beamPackages.mixRelease {
  inherit (beamPackages) erlang elixir;
  mixNixDeps = import ./deps.nix {
    inherit lib pkgs beamPackages;
    overrideFenixOverlay = finalPkgs: previousPkgs: {
      fenix = {
        stable = {
          inherit rustc cargo;
        };
      };
    };
}
```

:::{warning}
When debugging in `nix -L develop`,
you may want to edit the content of a dependency
(eg. to inject `|> IO.inspect(label: "foo")`),
you can do it in `deps/` but after each modification
if present in `_build/`, do not forget remove it
otherwise `mix deps.nix` will continue to use it
from `_build` instead of `_deps`.

So for example:
```bash
$ unset ERL_LIBS
$ $EDITOR deps/bonfire_common/lib/localise/cdlr.ex
$ rm -rf ./_build/prod/lib/bonfire_common/
$ MIX_DEBUG=1 iex --erl "-kernel shell_history enabled" -S mix deps.nix --verbose --tracer
# Loop back to $EDITOR
```
:::
