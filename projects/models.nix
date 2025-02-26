{
  lib,
  pkgs,
  sources,
}:
let
  yants = import sources.yants { };

  inherit (yants)
    string
    list
    option
    attrs
    enum
    either
    struct
    drv
    path
    restrict
    ;

  programType = struct "program" {
    name = string;
    source = drv;
    documentation = optionalStruct {
      build = option string;
      tests = option string;
    };
    examples = nonEmtpyAttrs (option exampleType);
  };

  serviceType = struct "service" {
    name = string;
    documentation = optionalStruct {
      config = option string;
    };
    examples = nonEmtpyAttrs (option exampleType);
  };

  exampleType = struct "example" {
    description = option string; # TODO: should this be non-optional?
    path = either string path;
    documentation = option string;
    tests = nonEmtpyAttrs drv;
  };

  optionalStruct = attrs: option (struct attrs);
  nonEmtpyAttrs = t: restrict "non-empty-attrs" (a: a != { }) (attrs t);
in
rec {
  project = struct {
    name = string;
    metadata = optionalStruct {
      summary = option string;
      subgrants = list string;
    };
    nixos = struct "nixos" {
      examples = option (attrs exampleType);
      tests = option (attrs (option drv));
      modules = struct "modules" {
        programs = option (attrs (option programType));
        services = option (attrs (option serviceType));
      };
    };
  };

  example = project {
    name = "foobar";
    nixos = rec {
      examples = {
        foobar-cli = {
          description = ''
            This is how you can run `foobar` in the terminal.
          '';
          path = "";
          documentation = "https://foo.bar/docs";
          tests = {
            # Each example must have at least one test.
            # If the line below is commented out, an error will be raised.
            inherit (tests) foobar-cli;
          };
        };
      };
      tests = {
        # Set to `null`: needed, but not available
        basic = null;

        # Needs to be a derivation. Error raised otherwise.
        #simple = "This will fail.";

        foobar-cli = derivation {
          name = "myname";
          builder = "mybuilder";
          system = "mysystem";
        };
      };
      modules = {
        # Attributes not defined in the data structure are not allowed.
        # Uncommenting the line below will raise an error.
        #hello = { };

        programs = {
          # Set to `null`: needed, but not available
          foobar = null;

          foobar-cli = {
            name = "foobar-cli";
            source = derivation {
              name = "foobar-cli-src";
              builder = "mybuilder";
              system = "mysystem";
            };
            # Each program must have at least one example.
            # Examples can be null to indicate that they're needed.
            examples = {
              inherit (examples) foobar-cli;

              # needed, not available
              foobar-tui = null;
            };
          };

          # Not set: not needed
        };
      };
    };
  };
}
