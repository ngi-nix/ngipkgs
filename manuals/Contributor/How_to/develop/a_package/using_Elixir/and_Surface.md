{#Contributor_How_to_develop_a_package_using_Elixir_and_Surface}
# How to develop a package using Elixir and Surface?

Using [Surface UI](https://github.com/surface-ui/surface)
requires to build the Elixir dependencies into "$out"
and to keep the paths into the built artifacts.

This can be done by overriding the `buildMix` used to build all dependencies:
```nix
let
  beamPackages = beam.packages // {
    buildMix =
      previousArgs:
      beamPkgs.buildMix (
        lib.recursiveUpdate previousArgs {
          erlangDeterministicBuilds = false;
          postUnpack = previousArgs.postUnpack or "" + ''
            mkdir -p $out
            mv $sourceRoot $out/src
            sourceRoot=$out/src
            src=$(mktemp -d)
          '';
          postInstall = previousArgs.postInstall or "" + ''
            src=$out/src
            rm -rf _build
          '';
        }
      );
  };
in
beamPackages.mixRelease {
  inherit (beamPackages) erlang elixir;
  mixNixDeps = import ./deps.nix {
    inherit lib g beamPackages;
  };
}
```
