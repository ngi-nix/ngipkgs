# How to develop a package using Elixir with deps_nix {#Contributor_How_to_develop_a_package_using_Elixir_with_deps_nix}

`deps_nix` must be injected into the `deps` of the `mix.exs`,
to get something looking like:
```elixir
def deps do
  [ { :deps_nix, git: "https://github.com/code-supply/deps_nix" } ] ++
  existing_deps
end
```
This could be done with `postPatch` using `substituteInPlace mix.exs --replace-fail`.

`deps.nix` can then be generated with something like:
```bash
mix local.hex --force --if-missing
mix local.rebar --force --if-missing
mix deps.get --only prod
mix deps.nix
nixfmt deps.nix
```

The resulting `deps.nix` can then be tracked by the version control software
and used like this, reusing `rustc` and `cargo` from `pkgs`:

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
