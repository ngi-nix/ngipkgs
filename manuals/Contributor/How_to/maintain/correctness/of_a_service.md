{#Contributor_How_to_maintain_correctness_of_a_service}
# How to maintain correctness of a service?

Whenever a package provides a check to validate its configuration,
it should be used (if possible at build-time).

Most notably, such a validation check should be used
instead of declaring all possible options in `settings`.
Instead, `freeformType` should be used, and only options
used elsewhere in the service module should be declared with a correct type.

```nix
configFile = lib.mkOption {
  type = lib.types.package;
  internal = true;
  default = (json.generate "config.json" cfg.settings).overrideAttrs (previousAttrs: {
    preferLocalBuild = true;
    # None of the usual phases are run here because runCommandWith uses buildCommand,
    # so just append to buildCommand what would usually be a checkPhase.
    buildCommand =
      previousAttrs.buildCommand
      + lib.optionalString cfg.checkConfig ''
        ln -s $out config.json
        install -D -m 644 /dev/stdin keys/radicle.pub <<<"ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIBgFMhajUng+Rjj/sCFXI9PzG8BQjru2n7JgUVF1Kbv5 snakeoil"
        export RAD_HOME=$PWD
        ${lib.getExe' pkgs.buildPackages.radicle-node "rad"} config >/dev/null || {
          cat -n config.json
          echo "Invalid config.json according to rad."
          echo "Please double-check your services.radicle.settings (producing the config.json above),"
          echo "some settings may be missing or have the wrong type."
          exit 1
        } >&2
      '';
  });
};
```

```{toctree}
of_a_service/by_validating_configurations
```
