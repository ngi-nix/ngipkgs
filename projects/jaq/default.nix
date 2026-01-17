{
  lib,
  pkgs,
  sources,
  ...
}@args:

{
  metadata = {
    summary = "Jaq is a data wrangling tool focusing on correctness, speed, and simplicity";
    subgrants = {
      Commons = [
        "Polyglot-jaq"
      ];
      Entrust = [
        "jaq"
      ];
    };
  };

  nixos.modules.programs = {
    jaq = {
      name = "jaq";
      module = ./programs/jaq/module.nix;
      examples.basic = {
        module = ./programs/jaq/examples/basic.nix;
        description = "Enable the jaq program";
        tests.basic.module = ./programs/jaq/tests/basic.nix;
      };
    };
  };

  nixos.demo.shell = {
    module = ./programs/jaq/examples/basic.nix;
    module-demo = ./module-demo.nix;
    description = ''
      A demo shell for testing jaq, a data wrangling tool with formal semantics similar to jq.

      Let's get a basic understanding of jaq's capabilities:

      Here, we can pass in a set or object full of numbers and have jaq add them together.

      $ echo '{"a": 1, "b": 2}' | jaq 'add' # equal to 3

      We can also do more complicated operations like mapping over a list and using conditionals:

      $ echo '[0, 1, 2, 3]' | jaq 'map(.*2) | [.[] | select(. < 5)] | add' # equal to 6

      Finally, jaq will fail if any malformed input is passed

      $ echo "0, 1, 4, " | jaq
    '';

    tests.basic.module = ./programs/jaq/tests/shell.nix;
  };
}
