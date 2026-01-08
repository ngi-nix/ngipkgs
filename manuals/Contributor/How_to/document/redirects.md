(Contributor_How_to_document_redirects)=
# How to document redirects?

When `doc-devmode` spits out an error like:
```
nixos_render_docs.redirects.RedirectsError:
Identifiers present in the source must have a mapping in the redirects file.
    - Contributor_How_to_optimize

This can happen when an identifier was added, renamed, or removed.

    Added new content?
        $ redirects add-content <identifier> <path>
    often:
        $ redirects add-content <identifier> index.html

    Moved existing content to a different output path?
        $ redirects move-content <identifier> <path>

    Renamed existing identifiers?
        $ redirects rename-identifier <old-identifier> <new-identifier>

    Removed content? Redirect to alternatives or relevant release notes.
        $ redirects remove-and-redirect <identifier> <target-identifier>
```

This can be fixed by adding a redirect into `doc/redirects.json`,
pointing to `Contributor.html` (resp. `User.html`)
when the identifier is in the Contributor's Manual (resp. User's Manual):
```bash
nix -L develop -f . shell -c doc-redirects add-content Contributor_How_to_optimize Contributor.html
```

Alternatively, for more control one can edit `doc/redirects.json` with a text editor.
