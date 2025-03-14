{
  lib,
  pkgs,
  sources,
}@args:

{
  # NOTE:
  # - Check `projects/models.nix` for a more detailed project structure
  # - Each program/service must have at least one example
  # - Set attributes to `null` to indicate that they're needed, but not available
  metadata = {
    summary = ''
      Project summary.
    '';
    subgrants = [
      "FooBar"
      "FooBar-CLI"
    ];
  };

  # Programs
  nixos.modules.programs = {
    foobar = {
      name = "foobar";
      module = ./programs/foobar/module.nix;
      examples.foobar = {
        module = ./programs/foobar/examples/foobar/module.nix;
        description = "";
        tests.basic = ./programs/foobar/examples/foobar/tests/basic.nix;
      };
      links = {
        build = {
          text = "FooBar Documentation";
          url = "https://foo.bar/build";
        };
        test = {
          text = "FooBar Documentation";
          url = "https://foo.bar/test";
        };
      };
    };

    # Needed, but not available
    foobar-cli = null;
  };

  # Services
  nixos.modules.services = {
    foobar = {
      name = "foobar";
      module = ./services/foobar/module.nix;
      examples.foobar = {
        module = ./services/foobar/examples/foobar/module.nix;
        description = "";
        tests.basic = ./services/foobar/examples/foobar/tests/basic.nix;
      };
      links = {
        build = {
          text = "FooBar Service Documentation";
          url = "https://foo.bar/service";
        };
      };
    };
  };
}
