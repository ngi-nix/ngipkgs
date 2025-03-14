# Contributing to NGIpkgs

This document is for people who want to contribute to NGIpkgs.
This involves interacting with changes proposed as [pull requests](https://docs.github.com/pull-requests) on [GitHub](https://github.com/) to the [NGIpkgs](https://github.com/ngi-nix/ngipkgs/) repository (which you're in right now).

This document assumes that you already know:

- [How to create a Nix package](https://nix.dev/tutorials/packaging-existing-software#).
- [How to use GitHub and Git](https://docs.github.com/en/get-started/quickstart/hello-world).

In addition, a GitHub account is required, which you can create on the [GitHub sign-up page](https://github.com/signup).

## When to create pull requests to NGIpkgs

Packagers are encouraged to contribute Nix packages of NGI projects to Nixpkgs, instead of to this repository.
However, there may be reasons speaking against that, including:

- Making the package available more quickly.
- The package is not a [good candidate for Nixpkgs](https://github.com/NixOS/nixpkgs/blob/master/pkgs/README.md#quick-start-to-adding-a-package).
- The package is a good candidate for Nixpkgs, but no one is willing to be a maintainer :cry:.

In any case, it is encouraged to create a pull request to Nixpkgs, then to this repository, with a comment linking to the Nixpkgs pull request in the description and the Nix expressions.

## Documentation style guide

When contributing documentation, do not split lines at arbitrary character lengths.
Instead, write one sentence per line, as this makes it easier to review changes.

## How to create pull requests to NGIpkgs

1. Set up a local version of NGIpkgs.
   If you don't have write access to NGIpkgs, create a [fork](https://github.com/ngi-nix/ngipkgs/fork) of the repository and clone it.

   ```ShellSession
   git clone https://github.com/some-owner/ngipkgs.git
   cd ngipkgs
   ```

1. Create and switch to a new Git branch.

   ```ShellSession
   git checkout -b some-branch
   ```

1. To add a package, start by creating a `package.nix` file in the package directory `pkgs/by-name/some-package`, where `some-package` will be the package attribute name.

   ```ShellSession
   mkdir -p pkgs/by-name/some-package
   $EDITOR pkgs/by-name/some-package/package.nix
   ```

   Make sure to:

   - Test the package on `x86_64-linux`.

     ```ShellSession
     git add pkgs/by-name/some-package
     nix build .#some-package
     ```

   - Format the Nix expressions with [nix fmt](https://nixos.org/manual/nix/stable/command-ref/new-cli/nix3-fmt.html).

     ```ShellSession
     nix fmt pkgs/by-name/some-package
     ```

   An existing example is [libgnunetchat](https://github.com/ngi-nix/ngipkgs/blob/main/pkgs/by-name/libgnunetchat/package.nix).

1. Check if the project already exists in `projects/some-project`.
   If it does not exist, you can copy the project template and edit it with relevant details:

   ```shellSession
   cp -r templates/project projects/some-project
   $EDITOR projects/some-project/default.nix
   ```

1. To add a NixOS service module, start by editing the `default.nix` file in the directory `projects/some-project`.

   ```shellSession
   $EDITOR projects/some-project/default.nix
   ```

   Make sure to:

   - Add the module options in `service.nix`, and reference that file in `default.nix`.
     For example:

     ```nix
     nixos.modules = {
       services.some-project.module = ./service.nix;
     };
     ```

     The module will then be accessible from `nixosModules.services.some-project`.
     Note that for new projects, it's ideal that you follow the [triaging template](#triaging-an-ngi-project) workflow and create a new issue, detailing some information about this project.

   - Add the module tests in `test.nix`, or under a test directory, and reference that file in `default.nix`.
     For example:

     ```nix
     nixos.tests.some-test = import ./test.nix args;
     ```

     The module tests will then be accessible from `checks.<system>.some-project`.

   - Test the module on `x86_64-linux`.

     ```shellSession
     git add pkgs/by-name/some-package projects/some-project
     nix build .#checks.x86_64-linux.projects/some-project/nixos/tests/some-test.driverInteractive
     ./result/bin/nixos-test-driver # Start a shell
     # Once in the spawned shell, start a VM that will execute the tests
     start_all() # Run the VM
     ```

   - Format the Nix expressions with [nix fmt](https://nixos.org/manual/nix/stable/command-ref/new-cli/nix3-fmt.html).

     ```ShellSession
     nix fmt projects/some-project
     ```

   An existing example is [AtomicData](https://github.com/ngi-nix/ngipkgs/tree/main/projects/AtomicData).

1. Commit the changes and push the commits.

   ```ShellSession
   git commit -m "some-message"
   git push --set-upstream origin some-branch
   ```

1. Create a [pull request to NGIpkgs](https://github.com/ngi-nix/ngipkgs/pulls).
   Respond to review comments, potential CI failures, and potential merge conflicts by updating the pull request.
   Always keep the pull request in a mergeable state.

## Triaging an NGI project

The following information is needed to [open an issue for a new NGI project](https://github.com/ngi-nix/ngipkgs/issues/new?template=project-triaging.yaml):

1. Navigate to <https://nlnet.nl/project/>.
   In the search bar, type the project name and look for any related projects.

   ```md
   - https://nlnet.nl/project/foobar
   - https://nlnet.nl/project/foobar-core
   ```

   In the project pages, look for any `website` or `source code` links and open them.

1. We'd like to know some information about the `framework` and `dependency management` tools the project is using which helps us to estimate the time and effort needed to package it. If possible, we'd also like to know about Nix development environments, if they exist in the repo.

   ```md
   - Language/Framework: Python/Django
   - Dependency management: pip
   - Development environment: [default.nix, shell.nix, flake.nix, devenv.nix, ...](<FILE_LINK>)
   ```

1. In the project's website, look for any tabs or buttons that lead to the documentation. You may also use your favorite search engine and look for `<PROJECT_NAME> documentation`.
   The most important information we need are the instructions for building the project from source and examples for using it.
   If the project has multiple components, it would be ideal to have this information for each one of them.

   ```md
   - Usage Examples:
     - https://foo.bar/docs/quickstart
   - Build from source/Development:
     - foobar-cli: https://foo.bar/docs/dev/cli
     - foobar-mobile: https://foo.bar/docs/dev/mobile
   ```

1. Go to the [nixpkgs search](https://search.nixos.org/packages) and [services search](https://search.nixos.org/options?) and check if anything related to the project is already packaged.

   ```md
   - Packages:
     - [<NAME>](<SOURCE_LINK>)
   - Services:
     - [<NAME>](<SOURCE_LINK>)
   ```

<!-- TODO: Add details about how to do more production-like deployments that require non-default config options. -->

<!-- TODO: How to import all of NGIpkgs as an input to an existing NixOS configuration, in order to deploy a service alongside other services on the same virtual or physical machine. -->
