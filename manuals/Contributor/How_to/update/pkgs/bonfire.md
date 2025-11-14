{#Contributor_How_to_update_pkgs_bonfire}
# How to update `pkgs.bonfire`?

[Bonfire](https://bonfirenetworks.org) package, `pkgs.bonfire`,
is currently maintained within [NGIpkgs](#User_What_is_NGIpkgs).
Its level of complexity is high, and its number of dependencies is huge.
Its main language is Elixir whose infrastructure is currently
not used much inside Nixpkgs, hence prone to:
- bugs,
- shortcomings of the infrastructure and supporting tools,
- poor understanding of how things should be done.

Hopefully, [deps_nix](https://github.com/code-supply/deps_nix)
(improving upon [mix2nix](https://github.com/ydlr/mix2nix))
is able to generate `pkgs/by-name/bonfire/deps.nix`:
- supporting `mix.exs`'s `:git` dependencies;
- supporting Elixir libraries using foreign Rust libraries;
- supporting fixes for specific Elixir dependencies.

Because Bonfire itself has a lot of moving and unstable pieces,
it may be wise to update it as frequently as possible
to spot problems as soon as possible
and [raise them to upstream](https://github.com/bonfire-networks/bonfire-app/issues)
which has a record of welcoming and fixing them diligently.

The usual `nix develop -f . shell -c update bonfire` should check or update:
- `pkgs.bonfire.src` in `pkgs/by-name/bonfire/package.nix`
- `pkgs.bonfire.mixNixDeps.*.src` in `pkgs/by-name/bonfire/deps.nix`
- `pkgs.bonfire.mixNixDeps.*.passthru.yarnOfflineCache` in `pkgs/by-name/bonfire/deps/*/yarnOfflineCache.hash`
- `pkgs.bonfire.mixNixDeps.*.passthru.yarnOfflineCache.missingHashes` in `pkgs/by-name/bonfire/deps/*/missingHashes.json`

:::{warning}
`bonfire.update.script` will not update `bonfire.mixNixDeps.evision.opencv`
which is currently a frontport of an old version of `opencv`
since `evision-0.2.14` does not support `opencv-4.12` of `nixos-25.11`
Relevant issues:
- https://github.com/cocoa-xu/evision/issues/289
- https://github.com/cocoa-xu/evision/issues/21
:::

Running `pkgs.bonfire.update.script` consumes a few hundreds of MiB
and can take as long as an hour due to `mix deps.nix`
needing to compile a part of each Elixir dependency.
