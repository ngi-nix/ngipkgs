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

1. When contributing to a project, start by checking if it has an entry in `projects/some-project`.
   If the entry does not exist, copy the project template and edit it with relevant details:

   ```shellSession
   cp -r maintainers/templates/project projects/some-project
   $EDITOR projects/some-project/default.nix
   ```

   Note that for new projects, it's ideal that you follow the [triaging template](#triaging-an-ngi-project) workflow and create a new issue, detailing some information about this project.
   This will allow you to get more familiar with the project and fill out the template more easily.

1. To add a NixOS service module, start by editing the `default.nix` file in the directory `projects/some-project`.

   ```shellSession
   $EDITOR projects/some-project/default.nix
   ```

   Make sure to:

   - Add the module options in `module.nix`, and reference that file in `default.nix`.
     For example:

     ```nix
     nixos.modules = {
       services.some-project.module = ./module.nix;
     };
     ```

     The module will then be accessible from `nixosModules.services.some-project`.

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

## How to update a package

1. To update a package, open the `pkgs/by-name/some-package/package.nix` in your text editor, where `some-package` will be the package attribute name.

   ```ShellSession
   $EDITOR pkgs/by-name/some-package/package.nix
   ```

1. Open the package's homepage or source repository and check if a new version is available, which can be the latest release tag or the commit revision.
   This information is usually available from the `meta.homepage` attribute, but can also be found in `src` as well.

1. Replace the `version` attribute in the derivation with the new version, but make sure that the package versioning fits the [Nixpkgs guidelines](https://github.com/NixOS/nixpkgs/blob/master/pkgs/README.md#versioning).

1. Replace hashes with empty strings. Example:

   ```nix
   sha256 = "sha256-18FKwP0XHoq/F8oF8BCLlul/Xb30sd0iOWuiKkzpPLI=";
     |
     v
   sha256 = "";
   ```

1. Build the package

   ```
   nix build .#checks.x86_64-linux.packages/<package_name>
   ```

1. The build will fail because the hashes are empty, but it will return the correct hash.
   Replace the empty hash with the correct hash and build again. Example:

   ```
   error: hash mismatch in fixed-output derivation '/nix/store/xxkj74gnza5rw5xyawzvlafbvbb76qdq-source.drv':
           likely URL: https://github.com/holepunchto/corestore/archive/v7.0.23.tar.gz
            specified: sha256-AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA=
               got:    sha256-oAsyv10BcmInvlZMzc/vJEJT9r+q/Rosm19EyblIDCM=
   ```

1. Make sure that all vendored hashes are also updated as well (e.g. cargoHash, npmDepsHash, ...)

1. After the build succeeds, verify that the package works, if possible.
   This means running package tests if they're available or at least verify that the built package is not broken with something like `program_name --help`.

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

## Adding/Exposing an NGI project

1. Copy the project template to the projects directory:

   ```
   cp -r maintainers/templates/project projects/<project_name>
   ```

1. Search for `NGI Project: <project_name>` in the [Ngipkgs issues](https://github.com/ngi-nix/ngipkgs/issues?q=is%3Aissue%20state%3Aopen%20label%3A%22NGI%20Project%22) page.
   If a page with that name exists, use the information available there in the next step.
1. Follow the instructions inside the `projects/<project_name>/default.nix` file and fill in the missing data about the project.
1. Check that the code is valid by running the test locally:

   ```
   # examples
   $ nix build .#checks.x86_64-linux.projects/<project_name>/nixos/examples/<example_name>
   
   # tests
   $ nix build .#checks.x86_64-linux.projects/<project_name>/nixos/tests/<test_name>
   ```

1. Run the Nix code formatter with `nix fmt`
1. Commit your changes and [create a new PR](#how-to-create-pull-requests-to-ngipkgs)

<!-- TODO: Add details about how to do more production-like deployments that require non-default config options. -->

<!-- TODO: How to import all of NGIpkgs as an input to an existing NixOS configuration, in order to deploy a service alongside other services on the same virtual or physical machine. -->

## Asking for help

Please ask questions on the [public NGIpkgs Matrix room](https://matrix.to/#/#ngipkgs:matrix.org).
