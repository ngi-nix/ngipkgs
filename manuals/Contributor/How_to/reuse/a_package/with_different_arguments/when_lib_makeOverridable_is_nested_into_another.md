{#Contributor_How_to_reuse_a_package_with_different_arguments_when_lib_makeOverridable_is_nested_into_another}
# How to reuse a package with different arguments when `lib.makeOverridable` is nested into another?

It's currently (as of `nixos-25.11`) not yet possible.
Because [`lib.makeOverridable`](https://nixos.org/manual/nixpkgs/unstable/#sec-lib-makeOverridable)
overrides the `override` attribute without giving access to the previous attrset.

Issue: <https://discourse.nixos.org/t/override-nested-attrset/41803>

Because this situation arises on each call to `callPackage`:
1. [`<pkg>.overrideAttrs`](https://nixos.org/manual/nixpkgs/stable/#sec-pkg-overrideAttrs) should be preferred to provide an overriding mechanism,
meaning derivation should pull overridable settings from `finalAttrs` or `finalAttrs.passthru`
for types that cannot be serialized to an environment variable.
2. Helpers should be written with [`lib.extendMkDerivation`](https://nixos.org/manual/nixpkgs/stable/#function-library-lib.customisation.extendMkDerivation)
3. Depending on what you need to `override` you may instead
be able to use a wrapper (like `pkgs.writeShellApplication` or `pkgs.makeWrapper`).
