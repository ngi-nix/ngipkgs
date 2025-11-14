{#Contributor_How_to_maintain_updatability_of_a_package_with_multiple_updaters}
# How to maintain updatability of a package with multiple updaters?

With [`_experimental-update-script-combinators.sequence`](https://github.com/NixOS/nixpkgs/blob/master/pkgs/common-updater/combinators.nix):

```nix
passthru = {
  update = callPackage ./update.nix { };
  updateScript = _experimental-update-script-combinators.sequence [
    (gitUpdater {
      rev-prefix = "v";
      ignoredVersions = ".*rc.*";
    })
    {
      command = [ (lib.getExe update.script) ];
      supportedFeatures = [ "silent" ];
    }
  ];
};
```
