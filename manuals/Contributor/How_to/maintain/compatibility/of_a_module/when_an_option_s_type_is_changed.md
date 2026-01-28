{#Contributor_How_to_maintain_compatibility_of_a_module_when_an_option_s_type_is_changed}
# How to maintain compatibility of a module when an option's `type` is changed?

[lib.types.coercedTo](https://nixos.org/manual/nixos/unstable/#sec-option-types-composed)
can be used.

Before:
```nix
options = {
  include = lib.mkOption {
    type = with lib.types; nullOr path;
    default = null;
    description = ''
      File to include in the configuration.
    '';
  };
};

```
After:
```nix
options = {
  include = lib.mkOption {
    type = with lib.types; coercedTo (nullOr path) (x: if x == null then [] else [x]) (listOf path);
    default = [ ];
    description = ''
      Files to include in the configuration.
    '';
  };
};
```
