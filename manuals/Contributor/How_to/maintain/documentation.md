{#Contributor_How_to_maintain_documentation}
# How to maintain documentation?

To check that the manuals always build
(eg. no option with a missing `description` or `defaultText`),
your `.git/hooks/pre-push` should contain:
```bash
#!/usr/bin/env bash
set -eux
nix -L build -f. manuals.man
```
