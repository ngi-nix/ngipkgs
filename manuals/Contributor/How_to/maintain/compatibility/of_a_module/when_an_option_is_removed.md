{#Contributor_How_to_maintain_compatibility_of_a_module_when_an_option_is_removed}
# How to maintain compatibility of a module when removing an option?

With `lib.mkRenamedOptionModule`.

For example, this removes `system.nixosVersion`,
but guides the user to use `system.nixos.version` instead:
```nix
import = [
  (lib.mkRenamedOptionModule [ "system" "nixosVersion" ] [ "system" "nixos" "version" ])
];
```
