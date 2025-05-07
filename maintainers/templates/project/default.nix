{
  lib,
  pkgs,
  sources,
}@args:

{
  # NOTE:
  # - Each program/service must have at least one example
  # - Set attributes to `null` to indicate that they're needed, but not available
  # - Remove comments that are only relevant to the template when using it
  metadata = {
    summary = "Short summary that describes the project";
    subgrants = [
      # 1. Navigate to the [NLnet project list](https://nlnet.nl/project/)
      # 2. Enter the project name in the search bar
      # 3. Review all the entries returned by the search
      # 4. Collect the links to entries that relate to the project
      #
      # For example, for a project called `Foobar`, this can be something like:
      #
      #   - https://nlnet.nl/project/Foobar
      #   - https://nlnet.nl/project/Foobar-mobile
      #
      # The subgrants will then be:
      #
      "Foobar"
      "Foobar-mobile"
    ];
    # Top-level links for things that are in common across the whole project
    # Remove the `links` attribute below if no such links exist
    links = {
      exampleLink = {
        text = "Title";
        url = "<URL>";
      };
    };
  };

  # NOTE: Replace `_programName_` with the actual program name
  nixos.programs = {
    _programName_ = {
      name = "program name";
      # if a project has `packages`, add them inside the `module.nix` file
      module = ./programs/_programName_/module.nix;
      examples.basic = {
        module = ./programs/_programName_/examples/basic.nix;
        description = "";
        tests.basic = import ./programs/_programName_/tests/basic.nix args;
      };
      # Add relevant links to the program (if they're available)
      # else, remove the `links` attribute below
      links = {
        build = {
          text = "Build from source";
          url = "<URL>";
        };
        test = {
          text = "Test instructions";
          url = "<URL>";
        };
      };
    };
  };

  # NOTE: Replace `_serviceName_` with the actual service name
  nixos.services = {
    _serviceName_ = {
      name = "service name";
      # Check if the service exists in https://search.nixos.org/options?
      # If it does, click on one of its options and copy the text in the `Declared in` field
      # into the `module` attribute:
      #
      # ```nix
      # module = "${sources.inputs.nixpkgs}/<DECLARED_IN_TEXT>";
      # ```
      #
      # Example (Cryptpad):
      #
      # ```nix
      # module = "${sources.inputs.nixpkgs}/nixos/modules/services/web-apps/cryptpad.nix";
      # ```
      #
      # Note: we can either use the module in nixpkgs or make one ourselves
      # inside a `module.nix` file, but we can't do both at the same time.
      #
      module = ./services/_serviceName_/module.nix;
      examples.basic = {
        module = ./services/_serviceName_/examples/basic.nix;
        description = "";
        tests.basic = import ./services/_serviceName_/tests/basic.nix args;
      };
      # Add relevant links to the service (if they're available)
      # else, remove the `links` attribute below
      links = {
        build = {
          text = "Build from source";
          url = "<URL>";
        };
        test = {
          text = "Test instructions";
          url = "<URL>";
        };
      };
    };
  };
}
