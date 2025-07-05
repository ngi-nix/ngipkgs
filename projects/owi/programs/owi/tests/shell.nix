{
  sources,
  ...
}:
{
  name = "owi usage example";

  nodes = {
    machine =
      { pkgs, ... }:
      {
        imports = [
          sources.modules.ngipkgs
          sources.modules.programs.owi
          sources.examples.owi.basic
        ];

        environment.etc."owi.rs".source = pkgs.writeText "owi.rs" ''
          use owi_sym::Symbolic;

          fn mean_one(x: i32, y: i32) -> i32 {
              (x + y)/2
          }

          fn mean_two(x: i32, y: i32) -> i32 {
              (y + x)/2
          }

          fn main() {
              let x = i32::symbol();
              let y = i32::symbol();
              // proving the commutative property of addition!
              owi_sym::assert(mean_one(x, y) == mean_two(x, y))
          }
        '';
      };
  };

  testScript =
    { nodes, ... }:
    ''
      start_all()

      # testing
      machine.succeed("owi rust --fail-on-assertion-only /etc/owi.rs")
    '';
}

