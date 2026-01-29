{#Contributor_How_to_document}
# How to document?

The documentation of NGIpkgs:
- is written in the [MyST (Markedly Structured Text)](https://myst-parser.readthedocs.io/en/latest/index.html)
language, a superset of CommonMark.

- is structured following with the
[Diátaxis](https://diataxis.fr)
framework for technical documentation.

More precisely, patterns currently in use to structure the documentation are:
```
Contributor/Exercise_to/<MainConcern>/<RelatedConcern>/<Scope>
Contributor/Exercise_to/<MainConcern>/<Scope>
Contributor/How_to/<MainConcern>/<RelatedConcern>/<Scope>
Contributor/How_to/<MainConcern>/<Scope>
Contributor/Release/<Scope>
Contributor/What_is/<Category>/<Scope>
Contributor/What_is/<Category>/<SubCategory>/<Scope>
Contributor/Why_to/<MainConcern>/<RelatedConcern>/<Scope>
Contributor/Why_to/<MainConcern>/<Scope>
User/Exercise_to/<MainConcern>/<RelatedConcern>/<Scope>
User/Exercise_to/<MainConcern>/<Scope>
User/How_to/<MainConcern>/<RelatedConcern>/<Scope>
User/How_to/<MainConcern>/<Scope>
User/Release/<Scope>
User/What_is/<Category>/<Scope>
User/What_is/<Category>/<SubCategory>/<Scope>
User/Why_to/<MainConcern>/<RelatedConcern>/<Scope>
User/Why_to/<MainConcern>/<Scope>
```

That is:
1. first a differentiation based upon NGIpkgs' main user-types
as [suggested by Diátaxis](https://diataxis.fr/complex-hierarchies/#two-dimensional-problems);
2. then a differentiation by tutorials, recipes, explanations and descriptions
as [recommended by Diátaxis](https://diataxis.fr/application/);
3. then a differentiation by concerns where a concern is whatever someone cares about;
4. and finally either a differentiation by related concern or by scope.

For explanations see: [](#Contributor_Why_to_document_with_Diataxis).

```{toctree}
document/with_a_live_preview.md
document/Exercise_to.md
document/How_to.md
document/Why_to.md
document/What_is.md
```
