# How to maintain updatability of a package with `gitUpdater` {#Contributor_How_to_maintain_updatability_of_a_package_with_gitUpdater}

To track stable versions, use something like this in `package.nix`:
```nix
passthru.updateScript = gitUpdater {
  rev-prefix = "v";
  ignoredVersions = ".*rc.*";
};

```
Alternatively, to track unstable versions, use something like this:
```nix
passthru.updateScript = gitUnstableUpdater {
  rev-prefix = "v";
};
```
