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
    summary = "mCaptcha is a backend component for a CAPTCHA system designed to provide a seamless user experience without unnecessary complexity.";
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
      "mCaptcha"
    ];
    # Top-level links for things that are in common across the whole project
    # Remove the `links` attribute below if no such links exist
    links = {
      website = {
        text = "Official website";
        url = "https://mcaptcha.org/";
      };
      documentation = {
        text = "Official documentation";
        url = "https://mcaptcha.org/docs/";
      };
    };
  };

  # NOTE: Replace `_serviceName_` with the actual service name
  nixos.modules.services = {
    mcaptcha = {
      name = "mcaptcha";
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
      module = ./services/mcaptcha/module.nix;
      examples.basic = {
        module = ./services/mcaptcha/examples/basic.nix;
        description = "Basic example of mCaptcha service.";
        tests.basic = import ./services/mcaptcha/tests/basic.nix args;
      };
      # examples = {
      #   bringService = {
      #     description = "use a database and other services running on a different node";
      #     module = ./services/mcaptcha/examples/basic.nix;
      #     tests.bringService = import ./services/mcaptcha/tests/bring-your-own-services.nix args;
      #   };
      #   createLocally = {
      #     description = "use a database and other services running on the same node";
      #     module = ./services/mcaptcha/examples/basic.nix;
      #     tests.createLocally = import ./services/mcaptcha/tests/create-locally.nix args;
      #   };
      # };
      links = {
        setup = {
          text = "Development setup";
          url = "https://github.com/mCaptcha/mCaptcha/blob/master/docs/HACKING.md";
        };
        deployment = {
          text = "Deployment instructions";
          url = "https://github.com/mCaptcha/mCaptcha/blob/master/docs/DEPLOYMENT.md";
        };
        configuration = {
          text = "Configuration instructions";
          url = "https://github.com/mCaptcha/mCaptcha/blob/master/docs/CONFIGURATION.md";
        };
      };
    };
  };
}
