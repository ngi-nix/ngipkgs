# Why to document with many files {#Contributor_Why_to_document_with_many_files}

## Pros {#Contributor_Why_to_document_with_many_files.Pros}
- Nudge into creating a tree of topics instead of a list of topics,
establishing a scope for each node.
The scope of each node should be as self-evident as possible by forming a self-contained sentence when considering its ancestors,
but even if when it's not, the meaning of the scope will be reinforced at each use,
creating expectations about where to find or put what.

- Nudge to keep the write-up on its specific topic,
and write into and refer to other sections instead of mixing topics.

- Enable to refer to (eg. using auto-completion of file-paths in any good text editor),
to browse (eg. using "Go to file under cursor" in any good text editor),
and to edit any specific section of the documentation
from inside the rest of the source code or commit descriptions,
without requiring going back and forth to a Web browser.

For example:
```nix
# Applies: ../../../doc/Contributor/Why_to/develop/a_package/using_Elixir/and_Surface/requires_a_hack.md
erlangDeterministicBuilds = false;
```

One may even imagine using those identifiers to do some manual linting,
eg. to keep track of which packages or module implements which recipe,
or should or must:
```nix
meta.diagnostics = {
  applies = [
    ../../../doc/How_to/maintain/up_to_date/a_package/using_a_Fixed_Output_Derivation.md
    ../../../doc/How_to/develop/a_package/using_Elixir/and_Surface.md
    ../../../doc/Why_to/develop/a_package/using_Elixir/with_deps_nix.md
  ];
  fixmes = [
  ];
  todos = [
  ];
};
```

## Cons {#Contributor_Why_to_document_with_many_files.Cons}
- Requires a lot of `{=include=}` blocks and filenames within.
- Requires additional thinking to decide where to put each write-up to be on-topic.
- When browsing the HTML rendition, it's the `#identifier`
that becomes easy to use. Alas, the tooling does not support the use of
a slash-separated path as `#identifier`.
- …
