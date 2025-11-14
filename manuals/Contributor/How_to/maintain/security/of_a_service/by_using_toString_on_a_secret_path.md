{#Contributor_How_to_maintain_security_of_a_service_by_using_toString_on_a_secret_path}
# How to maintain security of a service by using `toString` on a secret `path`?

:::{warning}
Even though [using `toString` on a `path` breaks installability](#Contributor_Why_to_maintain_installability_of_a_package_by_not_using_toString_on_a_path)
it can be used as a user error protection by keeping a path
that must always be out of the Nix store, out of the Nix store:
```nix
privateKeyFile = lib.mkOption {
  type = lib.types.str;
  description = "Private key file";
  apply = toString;
};
```
:::
