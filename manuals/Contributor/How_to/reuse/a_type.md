{#Contributor_How_to_reuse_a_type}
# How to reuse a type?

Sometimes a `type` is not accessible
because it's nested into another `type` (eg. `lib.types.attrsOf`).
But instead of recopying it to reuse it,
it's may possible to access it through `functor.payload.elemType`:
```nix
let
  elixirFormat = pkgs.formats.elixirConf { elixir = cfg.package.elixir; };
in
elixirFormat.type.functor.payload.elemType
```

Note however that when defining options inside a `lib.types.submodule` using `freeformType`,
there is usualy no need to specify a `type` to declared options
because they already inherit their `type` from the `freeformType`.
