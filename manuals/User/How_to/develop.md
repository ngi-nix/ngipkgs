{#User_How_to_develop}
# How to develop

When trying modifications to a software
that do not require changes to its packaging,
it may be handy to work within the exact same environment
used to package that software in NGIpkgs.

For more substancial modifications
requiring to modify the packaging of the software,
see [](#Contributor_How_to_develop_a_package).

Provisioning a development environment for a software `${package}`
can usually be done with something like this:
```console
$ nix -L develop -f github:ngi-nix/ngipkgs#${package}
$ cd $NIX_BUILD_TOP # if you want to work in a temporary directory
$ runPhase unpackPhase
$ runPhase patchPhase
$ runPhase configurePhase # if need be
$ runPhase buildPhase # if need be
$ runPhase checkPhase # if need be
$ runPhase installPhase # if need be
$ runPhase fixupPhase # if need be
$ runPhase installCheckPhase # if need be
$ runPhase distPhase # if need be
```

{#User_How_to_develop_Limitations}
# Limitations
But for substancial modifications,
such a `nix develop` directly on a package has some limitations:

1. You may rather want to work inside a version control system (VCS) (eg. Git),
for that you may first want to clone the exact `rev`ision used in NGIpkgs,
usually given by:
```console
$ nix -L expr -f github:ngi-nix/ngipkgs#${package}.src.rev
```
and change to that cloned directory before running `nix develop`.

2. Depending on the toolchain of `${package}`,
you may have troubles to modify dependencies of the main repository.
Please see and/or contribute to [](#User_Exercise_to_develop)
for specific toolchains/software.

3. Depending on the toolchain of `${package}`,
the dependencies specific to a development environment
(ie. not required when building for production)
may not be provisioned.
So it's may be more practical to use nix to only provision
the toolchain (eg.`cabal` for Haskell, `cargo` for Rust, `mix` for Elixir, …)
and use it to fetch the dependencies and go on as if `nix` were not used.

4. It does not provision additional tools useful
when developing (eg. LSP, linters, formatters, etc.).
So for more advance developing,
you may rather consider writing a `flake.nix` with a `devShells.default`
provisioning a complete development environement.

5. It does not enable to run tests requiring external services (like a database),
as done in NGIpkgs' tests running inside NixOS containers.
For that you may consider:
1. [devenv.sh](https://devenv.sh)
<!-- FixMe: needs nixos-modules to be configurable
2. or to reuse a NGIpkgs test `${test}` of a project `${project}` using a service `${service}`
with an overrided `${package}`'s `src` location with your local clone in `/path/to/local/clone`:
```console
$ nix -L build --impure --expr 'import (builtins.getFlake "github:ngi-nix/ngipkgs") {
    nixos-modules = [ ({ pkgs, ... }: { services.${service}.package = pkgs.${package}.overrideAttrs { src = /path/to/local/clone; }; }) ];
  }' hydrated-projects.${project}.nixos.tests.${test}
```
3. or the same in but in interactive mode enabling to access containers with SSH or exposing forwading ports to the hosts:
```console
$ nix -L run --impure --expr 'import (builtins.getFlake "github:ngi-nix/ngipkgs") {
    nixos-modules = [ ({ pkgs, ... }: { services.${service}.package = pkgs.${package}.overrideAttrs { src = /path/to/local/clone; }; }) ];
  }' hydrated-projects.${project}.nixos.tests.${test}.driverInteractive
```
For example:
```console
$ nix -L run --impure --expr 'import (builtins.getFlake "github:ngi-nix/ngipkgs") {
    nixos-modules = [ ({ pkgs, ... }: { services.bonfire.package = pkgs.bonfire.overrideAttrs { src = builtins.getFlake "github:bonfire-networks/bonfire-app"; }; }) ];
```
-->
