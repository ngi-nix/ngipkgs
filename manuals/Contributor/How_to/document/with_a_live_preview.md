{#Contributor_How_to_document_with_a_live_preview}
# How to document with a live preview?

To have a live-preview while editing the documentation,
[`devmode`](https://github.com/NixOS/nixpkgs/blob/master/pkgs/by-name/de/devmode/README.md)
can be used almost like in `nixpkgs`, the only difference is the name of the executable:
```bash
nix -L develop -f . shell -c doc-devmode
```

Remark(use): that live-preview is significantly slower than some alternatives
and one constantly has to painfully add an anchor to every title and every anchor to `doc/redirects.json`
with `doc-redirects add-content`,
but that's leveraging Nixpkgs' current tooling.
