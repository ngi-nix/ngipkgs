{#Contributor_How_to_update_inputs}
# How to update `inputs`?

`flake.nix` provides inputs for both flake and non-flake uses,
`inputs` being called `sources` in the rest of the code.
An input named `${input}` can be updated with:
```console
nix flake update ${input}
```

An input can temporarily be overrided to a local destination with:
```console
nix -L build --override-input ${input} git+file:///path/to/git/repo -f. ${installable}
```
