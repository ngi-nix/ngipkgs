{#Contributor_How_to_maintain_correctness_of_a_package_using_environment_variables}
# How to maintain correctness of a package using environment variables?

Instead of setting environment variables as top-level attributes, as in:
```nix
stdenv.mkDerivation {
  FOO = "bar";
}
```
they must be set in the sub-attribute `env`, as in:
```nix
stdenv.mkDerivation {
  env = {
    FOO = "bar";
  }
}
```
which preserves their `export` whenever an overrided
version of that derivation enables [`__structuredAttrs`](https://nix.dev/manual/nix/2.33/language/advanced-attributes.html#adv-attr-structuredAttrs).

Moreover, within [`<pkg>.overrideAttrs`](https://nixos.org/manual/nixpkgs/unstable/#sec-pkg-overrideAttrs) care must be taken
to preserve needed environment variables when modifying `env`.

:::{warning}
Contrary to `<pkg>.override`, `<pkg>.overrideAttrs` does not override using `lib.recursiveUpdate`,
hence the following is not preserving other environments variables from `previousAttrs.env`:
```nix
drv.overrideAttrs (finalAttrs: previousAttrs: {
  env.FOO = "bar";
}
```
while this does:
```nix
drv.overrideAttrs (finalAttrs: previousAttrs: {
  env = previousAttrs.env or { } // {
    env.FOO = "bar";
  }
```
:::
