---
name: "Task: add update script"
about: "Add an update script to a derivation"
title: "Add an update script to DERIVATION_NAME"
projects: Nix@NGI
type: task
labels: ''
assignees: ''
---

### Instructions

Add an update script to the derivation:

- Stable tag releases:

  ```nix
  passthru.updateScript = nix-update-script { };
  ```

- Unstable releases:

  ```nix
  passthru.updateScript = unstableGitUpdater { };
  ```

<!-- TODO: add instruction to trigger the update script, to make sure that it's working -->

For more information, see the [Nixpkgs documentation](https://github.com/NixOS/nixpkgs/blob/master/pkgs/README.md#automatic-package-updates) on this topic.

<!-- TODO: create contributor documentation for this task -->
