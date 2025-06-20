---
name: "Task: Update derivation (Nixpkgs)"
about: "Update a derivation in Nixpkgs"
title: "Update DERIVATION_NAME to NEW_VERSION in Nixpkgs"
projects: Nix@NGI
type: task
labels: ''
assignees: ''
---

### Instructions

Follow the [contribution guide in the Nixpkgs repository](https://github.com/NixOS/nixpkgs/blob/master/pkgs/README.md) and:

- Update the derivation to the version in the title
- Make sure that it builds, locally: `nix-build -A DERIVATION_NAME`
- Add an [update script](https://github.com/NixOS/nixpkgs/blob/master/pkgs/README.md#automatic-package-updates), if it's missing

  ```nix
  passthru.updateScript = nix-update-script { };
  ```

  or for unstable releases:

  ```nix
  passthru.updateScript = unstableGitUpdater { };
  ```

- Add the ngi team in `meta.teams`, if it's not already there:

  ```nix
  meta.teams = with lib.teams; [ ngi ];
  ```
