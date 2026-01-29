{#Contributor_Why_to_maintain_correctness_of_a_package_by_using_env}
# Why to maintain correctness of a package by using `env`?

When environment variables are declared in the sub attrset `env` of `pkgs.mkDerivation`
they remain `export`ed even when `__structuredAttrs` is enabled,
eg. as argument for a build-helper, or with an `overrideAttrs`.
For more details see: <https://github.com/NixOS/nix/issues/14847>.
