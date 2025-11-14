{#Contributor_How_to_maintain_compatibility_of_a_module_when_an_option_s_name_is_changed}
# How to maintain compatibility of a module when an option's `name` is changed?

With `lib.mkAliasOptionModule`.

For example, this aliases `systemd.service` to `systemd.services`:
```nix
imports = [
  (lib.mkAliasOptionModule [ "users" "extraUsers" ] [ "users" "users" ])
];
```

Or with `lib.modules.mkAliasAndWrapDefsWithPriority`,
when the option is nested in `lib.types.attrsOf`.
Here `datasets.*.useTemplate` is aliased to `datasets.*.use_template`:
```nix
datasets = lib.mkOption {
  type = lib.types.attrsOf (
    lib.types.submodule (
      { config, options, ... }:
      {
        config.use_template = lib.modules.mkAliasAndWrapDefsWithPriority lib.id (
          options.useTemplate or { }
        );
      }
    )
  );
};
```
