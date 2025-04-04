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
    summary = "";
    subgrants = [
      "FooBar"
      "FooBar-cli"
    ];
  };

  nixos.modules.programs = {
    foobar = {
      name = "foobar";
      module = ./module.nix;
      examples.foobar = {
        module = ./example.nix;
        description = "";
        tests.basic = ./test.nix;
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

    # needed, but not available
    foobar-cli = null;
  };

  # NOTE: same structure as programs
  nixos.modules.services = {
    module = "${sources.inputs.nixpkgs}/nixos/modules/services/networking/scion/scion.nix";
  };
}
