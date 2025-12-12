# How to reuse a package with different arguments when `lib.makeOverridable` is nested into another {#Contributor_How_to_reuse_a_package_with_different_arguments_when_lib_makeOverridables_is_nested_into_another}

It's currently (as of `nixos-25.11`) not yet possible.
Because [`lib.makeOverridable`](https://nixos.org/manual/nixpkgs/unstable/#sec-lib-makeOverridable)
overrides the `override` attribute without giving access to the previous attrset.

Issue: <https://discourse.nixos.org/t/override-nested-attrset/41803>

Depending on what you need to `override` you may instead be able to use a wrapper
(like `pkgs.writeShellApplication` or `pkgs.makeWrapper`)
or `overrideAttrs`.
