{
  lib,
  pkgs,
  sources,
}@args:

{
  # NOTE:
  # - Each program/service must have at least one example
  # - Set attributes to `null` to indicate that they're needed, but not available
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
  };

  # NOTE: Replace `_programName_` with the actual program name
  nixos.modules.programs = {
    _programName_ = {
      name = "program name";
      module = ./programs/_programName_/module.nix;
      examples.basic = {
        module = ./programs/_programName_/examples/basic.nix;
        description = "";
        tests.basic = ./programs/_programName_/tests/basic.nix;
      };
      # Add relevant links to the program, for example:
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

    # Needed, but not available
    foobar-cli = null;
  };

  # NOTE: Replace `_serviceName_` with the actual service name
  nixos.modules.services = {
    _serviceName_ = {
      name = "service name";
      module = ./services/_serviceName_/module.nix;
      examples.basic = {
        module = ./services/_serviceName_/examples/basic.nix;
        description = "";
        tests.basic = ./services/_serviceName_/tests/basic.nix;
      };
      # Add relevant links to the service, for example:
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
