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

## Triaging an NGI application

An NGI-funded application is triaged by collecting relevant information and resources related to its packaging, which can be in the form of links to source repositories, documentation, previous packaging attempts, ...
This task helps us understand the current packaging completion, which deliverables we need to implement and to estimate the time and effort it would take us to do so.

> [!NOTE]
>
> - This task should not exceed 1 Hour.
> - For some complete examples, please see:
>   - [NGI Project: Kaidan](https://github.com/ngi-nix/ngipkgs/issues/1072)
>   - [NGI Project: Galene](https://github.com/ngi-nix/ngipkgs/issues/663)

To start, open a [blank issue](https://github.com/ngi-nix/ngipkgs/issues/new?template=BLANK_ISSUE) in GitHub with the title `<PROJECT_NAME>: Triaged data`.
Then, for each of the following sections, copy the code blocks, follow the instructions, and add the data.

### Short summary

Provide a short description of the project.
This needs be brief and also capture the essence of what the project does.

   ```markdown
   ### Short summary 

   <!-- A short description of the project -->

   ```

### NLnet page(s)

1. Navigate to the [NLnet project list](https://nlnet.nl/project/)
2. Enter the project name in the search bar
3. Review all the entries returned by the search
4. Collect the links to entries that relate to the project

   ```markdown
   ### NLnet page(s)

   <!-- For example, for a project called `Foobar`, this can be something like:

   - <https://nlnet.nl/project/Foobar>
   - <https://nlnet.nl/project/Foobar-mobile> -->

   - 
   - 
   ```

### Resources

Provide the project's website and the location where the source code is hosted.
Additionally, include information about the programming languages, build tools used, as well as any dependency management systems in place.

   ```markdown
   ### Website

   <!-- The main project website, as found in the NLnet pages. -->

   - 

   ### Source repositories

   <!-- For example, for a project called `Foobar`, this can be something like:

    - https://github.com/foo/foobar
      - Language/Framework: Python
      - Dependency management: Nix
      - Nix development environment: [default.nix](https://github.com/foo/foobar/default.nix)

    - https://github.com/foo/foobar-mobile
      - Language/Framework: Java
      - Dependency management: Gradle
      - Nix development environment: -->

   - <REPOSITORY_LINK>
    - Language/Framework:
    - Dependency management:
    - Nix development environment:
   ```

> [!NOTE]
> Use your best judgment to gather information about the project.
> If you're uncertain about something, try using a search engine.
> If you're still unsure after that, it's okay to leave it empty and move on.

Next, provide any links to documentation and any other resource that can help with building the project from source or with configuring and using it.

   ```md
   ### Documentation

   <!-- Example for a project called `Foobar`:

   - Usage Examples:
     - https://foo.bar/docs/quickstart
   - Build from source/Development:
     - foobar-cli: https://foo.bar/docs/dev/cli
     - foobar-mobile: https://foo.bar/docs/dev/mobile
   - Other:
     - Wiki
     - Notes -->

   - Usage Examples:
    - 
    - 
   - Build from source/Development:
    - 
    - 
   - Other:
    - 
    - 
   ```

> [!TIP]
>
> On the project's website, look for tabs or buttons that lead to the documentation.
> You can also use your favorite search engine to search for <PROJECT_NAME> documentation.
> If no such page exists, check the source repositories, instead.

### Artefacts

List all project components and include links to any relevant documentation or information you can find about each one.

   ```markdown
   ### Artefacts

   <!-- Example for a project called `Foobar`:

   - CLI:
     - foobar:
         - documentation: https://foo.bar/docs/dev/build
         - examples: https://foo.bar/docs/usage
         - tests: https://github.com/foo/foobar/tests
   - Mobile Apps:
     - foobar-mobile:
         - documentation: https://foo.bar/docs/dev/mobile -->

   - CLI:
   - GUI:
   - Services/daemons:
   - Libraries:
   - Extensions:
   - Mobile Apps:
   ```

### Previous packaging

To avoid duplicaiton of effort and to correctly track our packaging progress, we also want to know whether or not any prior work has gone through packaging the project.

To do this, please go and search for the project's name and note any results from the following places:
    - The [ngipkgs/projects](https://github.com/ngi-nix/ngipkgs/tree/main/projects) and [pkgs/by-name](https://github.com/ngi-nix/ngipkgs/tree/main/pkgs/by-name) directories
    - **Non-archived** repositories in the [ngi-nix GitHub organisation](https://github.com/orgs/ngi-nix/repositories?language=&q=archived%3Afalse+&sort=&type=all)

   ```markdown
   ### NGIpkgs

   <!-- For example, for `Liberaforms`:
   - project: https://github.com/ngi-nix/ngipkgs/tree/main/projects/Liberaforms
     - programs/serivces:
       - https://github.com/ngi-nix/ngipkgs/blob/main/projects/Liberaforms/service.nix
     - examples:
       - https://github.com/ngi-nix/ngipkgs/tree/main/projects/Liberaforms/example.nix
     - tests:
       - https://github.com/ngi-nix/ngipkgs/tree/main/projects/Liberaforms/test.nix
   - pkgs/by-name:
     - https://github.com/ngi-nix/ngipkgs/tree/main/pkgs/by-name/liberaforms
   - ngi-nix repository
     - https://github.com/ngi-nix/liberaforms-flake -->
   
   - project:
   - pkgs/by-name:
   - ngi-nix repository:
   ```

Next, go to the nixpkgs search pages for
[packages](https://search.nixos.org/packages) and
[services](https://search.nixos.org/options?) and check if anything
related to the project is already packaged.

For packages, copy the package name along with the source URL.
For services, click on the module name to reveal more details, then copy the name and the URL from the `Declared in` field.

   ```markdown
   ### Nixpkgs/NixOS

   <!-- Example:
       - Packages:
           - [canaille](https://github.com/NixOS/nixpkgs/blob/nixos-unstable/pkgs/by-name/ca/canaille/package.nix#L134)
       - Services:
           - [services.canaille](https://github.com/NixOS/nixpkgs/blob/nixos-unstable/nixos/modules/services/security/canaille.nix) -->

   - Packages:
   - Services:
   
   ### Extra Information

   <!-- Anything interesting or helpful for packaging the project like notes, issues or pull requests -->
   ```

> [!NOTE]
> Similar names will be returned by the search if no exact matches are found.
> The most relevant entries at the top, so if you don't see anything that's related to the project there then it's likely not packaged in nixpkgs, yet.
>
> Example: Searching for Oku (web browser) might also return Okular (document viewver), which share a similar names, but which are totally unrelated.

## Exposing an NGI project

In order to display a project on <ngi.nixos.org>, its metadata must be added to this repository's source code in a certain format.

1. Copy the [project template](./maintainers/templates/project) to the projects directory:

   ```
   cp -r maintainers/templates/project projects/<project_name>
   ```

1. Follow the instructions inside the [`projects/<project_name>/default.nix`](./maintainers/templates/project/default.nix) file, and fill in the data based on the project's tracking issue.

   Project tracking issues are labeled with [`NGI Project`](https://github.com/ngi-nix/ngipkgs/issues?q=is%3Aissue%20state%3Aopen%20label%3A%22NGI%20Project%22).

1. Check that the code is valid by running the test locally:

   ```
   nix build .#checks.x86_64-linux.projects/<project_name>/nixos/tests/<test_name>
   ```

1. Run the Nix code formatter with `nix fmt`
1. Commit your changes and [create a new PR](#how-to-create-pull-requests-to-ngipkgs)

## Running and testing the overview locally

1. To run a local version of the [overview](https://ngi.nixos.org/), run a live overview watcher with:

   ```
   nix-shell --run devmode
   ```

2. The overview will automatically open in your default browser.

If you make any changes to the overview while running `devmode`, the server will automatically be reloaded with the new contents in a few seconds, after you save.

<!-- TODO: Add details about how to do more production-like deployments that require non-default config options. -->

<!-- TODO: How to import all of NGIpkgs as an input to an existing NixOS configuration, in order to deploy a service alongside other services on the same virtual or physical machine. -->

## Asking for help

Please ask questions on the [public NGIpkgs Matrix room](https://matrix.to/#/#ngipkgs:matrix.org).
