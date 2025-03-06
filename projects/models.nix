{
  lib,
  pkgs,
  sources,
  # TODO: arguably we can eventually translate this to the module system:
  #       - we only need to type-check in CI (e.g. by rendering the overview) and expose the values as regular attrs, so performance is not an issue
  #       - the module system has much more powerful types
  #       - the module system is maintained
  yants ? import sources.yants { inherit lib; },
}:
let
  inherit (yants)
    string
    list
    option
    attrs
    either
    eitherN
    struct
    drv
    path
    restrict
    function
    any
    ;

  urlType = struct "URL" {
    # link text
    text = string;
    # could be a hover/alternative text or simply a long-form description of a non-trivial resource
    description = option string;
    # we may later want to do a fancy syntax check in a custom `typdef`
    url = string;
  };

  moduleType = eitherN [
    absPath
    function
    (attrs any)
  ];

  # TODO: plugins are actually component *extensions* that are of component-specific type,
  #       and which compose in application-specific ways defined in the application module.
  #       we can't express that with yants, but with the module system, which gives us a bit of dependent typing.
  #       this also means that there's no fundamental difference between programs and services,
  #       and even languages: libraries are just extensions of compilers.
  pluginType = any;

  # TODO: make use of modular services https://github.com/NixOS/nixpkgs/pull/372170
  serviceType = struct "service" {
    name = option string;
    module = moduleType;
    links = optionalAttrs (option urlType);
    examples = optionalAttrs (option exampleType);
    extensions = optionalAttrs (option pluginType);
  };

  # TODO: port modular services to programs
  programType = struct "program" {
    name = option string;
    module = moduleType;
    links = optionalAttrs (option urlType);
    examples = optionalAttrs (option exampleType);
    extensions = optionalAttrs (option pluginType);
  };

  exampleType = struct "example" {
    description = string;
    module = moduleType;
    links = optionalAttrs (option urlType);
    tests = nonEmtpyAttrs testType;
  };

  # NixOS tests are modules that boil down to a derivation
  testType = option (either moduleType drv);

  optionalStruct = set: option (struct set);
  optionalAttrs = set: option (attrs set);
  nonEmtpyAttrs = t: restrict "non-empty attribute set" (a: a != { }) (attrs t);
  absPath = restrict "absolute path" (p: lib.pathExists p) (either path string);
in
rec {
  project = struct {
    name = option string;
    metadata = optionalStruct {
      summary = option string;
      subgrants = list string;
    };
    nixos = struct "nixos" {
      # TODO: Tests should really only be per example, in order to clarify that we care about tested examples more than merely tests.
      #       But reality is such that most NixOS tests aren't based on self-contained, minimal examples, or if they are they can't be extracted easily.
      #       Without this field, many applications will appear entirely untested although there's actually *some* assurance that *something* works.
      #       Eventually we want to move to documentable tests exclusively, and then remove this field, but this may take a very long time.
      tests = option (attrs testType);
      modules = struct "modules" {
        programs = optionalAttrs (option programType);
        services = optionalAttrs (option serviceType);
      };
      # An application component may have examples using it in isolation,
      # but examples may involve multiple application components.
      # Having examples at both layers allows us to trace coverage more easily.
      # If this tends to be too cumbersome for package authors and we find a way obtain coverage information programmatically,
      # we can still reduce granularity and move all examples to the application level.
      examples = option (attrs exampleType);
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
          module = { ... }: { };
          links = {
            website = {
              text = "FooBar Documentation";
              url = "https://foo.bar/docs";
            };
          };
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
            module =
              { lib, ... }:
              {
                enable = lib.mkEnableOption "foobar CLI";
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
