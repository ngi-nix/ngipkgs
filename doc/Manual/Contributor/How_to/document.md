# How to document {#Contributor_How_to_document}

The documentation of NGIpkgs is written using the [CommonMark](https://commonmark.org/) Markdown dialect,
with the same additional syntax extensions [enabled in Nixpkgs Reference Manual](https://github.com/NixOS/nixpkgs/blob/master/doc/README.md).
<!-- Alternative: nix.dev uses MyST, a superset of CommonMark
  -- but the infrastructure is a bit more complex.
  -->

Patterns currently in use to structure the documentation are:
```
Contributor/Exercise_to/<MainConcern>/<RelatedConcern>/<Scope>
Contributor/Exercise_to/<MainConcern>/<Scope>
Contributor/How_to/<MainConcern>/<RelatedConcern>/<Scope>
Contributor/How_to/<MainConcern>/<Scope>
Contributor/What_is/<Category>/<Scope>
Contributor/What_is/<Category>/<SubCategory>/<Scope>
Contributor/Why_to/<MainConcern>/<RelatedConcern>/<Scope>
Contributor/Why_to/<MainConcern>/<Scope>
User/Exercise_to/<MainConcern>/<RelatedConcern>/<Scope>
User/Exercise_to/<MainConcern>/<Scope>
User/How_to/<MainConcern>/<RelatedConcern>/<Scope>
User/How_to/<MainConcern>/<Scope>
User/What_is/<Category>/<Scope>
User/What_is/<Category>/<SubCategory>/<Scope>
User/Why_to/<MainConcern>/<RelatedConcern>/<Scope>
User/Why_to/<MainConcern>/<Scope>
```

That is:
1. first a differentiation [based upon user-types](https://diataxis.fr/complex-hierarchies/#two-dimensional-problems).
1. then a differentiation based upon the [usual Diátaxis recommendation](#Contributor_Why_to_document_with_Diataxis),
2. then a differentiation by concerns where a concern is whatever someone cares about,
3. and finally either a differentiation by related concern or by scope.

```{=include=} sections
document/with_a_live_preview.md
document/redirects.md
document/Exercise_to.md
document/How_to.md
document/Why_to.md
document/What_is.md
```
