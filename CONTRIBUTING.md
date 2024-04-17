# Contributing to NGIpkgs

This document is for people wanting to contribute to the implementation of NGIpkgs.
This involves interacting with implementation changes that are proposed using [GitHub](https://github.com/) [pull requests](https://docs.github.com/pull-requests) to the [NGIpkgs](https://github.com/ngi-nix/ngipkgs/) repository (which you're in right now).

This document assumes that you already know:

- How to [create a Nix package](https://nix.dev/tutorials/packaging-existing-software#).
- How to [use GitHub and Git](https://docs.github.com/en/get-started/quickstart/hello-world).

In addition, a GitHub account is required, which you can sign up for [here](https://github.com/signup).

## How to create pull requests

Packagers are encouraged to contribute NGI projects to Nixpkgs, instead of to this repository.
However, there are many reasons for not being able to do so, including:

- Expediting the public availability of a package prior to its acceptance into Nixpkgs and landing in a channel.
- Package is not a [good candidate for Nixpkgs](https://github.com/NixOS/nixpkgs/blob/master/pkgs/README.md#quick-start-to-adding-a-package).
- Package is a good candidate for Nixpkgs, but no one is willing to be a maintainer :cry:.

In any case, it is encouraged to create a pull request to Nixpkgs, then to this repository, with a comment linking to the pull request to Nixpkgs in the description and the Nix expressions.

---

Now that this is out of the way.
To create pull requests to NGIpkgs:

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

   To see how it’s done, an existing example is [libgnunetchat](https://github.com/ngi-nix/ngipkgs/blob/main/pkgs/by-name/libgnunetchat/package.nix).

1. To add a module, start by creating a `default.nix` file in the module directory `projects/someModule`.

   ```shellSession
   mkdir -p projects/someModule
   $EDITOR projects/someModule/default.nix
   ```

   Make sure to:

   - Add the module options in `service.nix`, and reference the file in `default.nix`.
     For example:

     ```nix
     nixos.modules = {
       services.some-module = ./service.nix;
     };
     ```

     The module will then be accessible from `nixosModules.services.some-module`.

   - Add the module tests in `test.nix`, or under a test directory, and reference the file in `default.nix`.
     For example:

     ```nix
     nixos.tests.some-test = import ./test.nix args;
     ```

     Then, pass the module tests through a package.
     For example, in `pkgs/by-name/some-package/package.nix`:

     ```nix
     passthru.tests.some-test = nixosTests.someModule.some-test;
     ```

     The module tests will then be accessible from `some-package.passthru.tests`.

   - Test the module on `x86_64-linux`.

     ```shellSession
     git add pkgs/by-name/some-package projects/someModule
     nix build .#some-package.passthru.tests.some-test.driverInteractive
     ./result/bin/nixos-test-driver # Start a shell
     # Once in the spawned shell, start a VM that will execute the tests
     start_all() # Run the VM
     ```

   - Format the Nix expressions with [nix fmt](https://nixos.org/manual/nix/stable/command-ref/new-cli/nix3-fmt.html).

     ```ShellSession
     nix fmt projects/someModule
     ```

   To see how it's done, an existing example is [Kbin](https://github.com/ngi-nix/ngipkgs/tree/main/projects/Kbin).

1. Commit the changes and push the commits.

   ```ShellSession
   git commit -m "some-message"
   git push --set-upstream origin some-branch
   ```

1. Create a pull request [to NGIpkgs](https://github.com/ngi-nix/ngipkgs/pulls).
   Respond to review comments, potential CI failures and potential merge conflicts by updating the pull request.
   Always keep the pull request in a mergeable state.

<!-- TODO: Add details about how to do more production-like deployments that require non-default config options. -->

<!-- TODO: How to import all of NGIpkgs as an input to an existing NixOS configuration, in order to deploy a service alongside other services on the same virtual or physical machine. -->
