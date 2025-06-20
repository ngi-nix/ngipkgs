---
name: "Task: Update derivation"
about: "Update a derivation"
title: "Update DERIVATION_NAME to the latest version"
projects: Nix@NGI
type: task
labels: ''
assignees: ''
---

### Instructions

Follow the [contribution guide in the Nixpkgs repository](https://github.com/NixOS/nixpkgs/blob/master/pkgs/README.md) and:

- [Add an update script](https://github.com/ngi-nix/ngipkgs/issues/new?template=task-drv-update-script.yaml), if it's missing
<!-- TODO: - Make sure that it works, by triggering it locally: `COMMAND` -->
- Add the ngi team in `meta.teams`, if it's not already there:

  ```nix
  meta.teams = with lib.teams; [ ngi ];
  ```
<!-- TODO: create contributor documentation for this task -->
