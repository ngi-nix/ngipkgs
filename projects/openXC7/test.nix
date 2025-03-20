{
  lib,
  sources,
  ...
}:
{
  name = "openxc7";

  # Can't mark this broken or conditionally define the test based on openxc7
  # availability, so stub it out in those situations

  nodes = {
    machine =
      { pkgs, ... }:
      {
        imports = [
          sources.modules.ngipkgs
          sources.modules.programs.openxc7
          sources.examples.openXC7.openxc7

          # If openxc7 unavailable, don't pull in
          (
            { pkgs, lib, ... }:
            {
              programs.openxc7.enable = lib.mkForce (!pkgs.openxc7.meta.broken);
            }
          )
        ];
        # Running OOM while building
        virtualisation.memorySize = 4096;

        environment = {
          etc."demo-projects".source = pkgs.fetchFromGitHub {
            owner = "openXC7";
            repo = "demo-projects";
            rev = "bceb172c3e11841e3289b0f604aed8ca1f15bbd5";
            hash = "sha256-gO9avqJnebp4AmziEjdj7OkYdJRE3wjhx+cdwBhxcZQ=";
          };

          systemPackages = with pkgs; [
            # Demo project needs make to run the build
            gnumake
          ];
        };
      };
  };

  testScript =
    { nodes, ... }:
    if (nodes.machine.programs.openxc7.enable) then
      ''
        start_all()

        # We need it writable
        machine.succeed("cp -Lr --no-preserve=all /etc/demo-projects /root/demo-projects >&2")

        # Build an example
        machine.succeed("openxc7-env -c -- 'make -C /root/demo-projects/blinky-qmtech >&2'")
      ''
    else
      ''
        log.info("NOTE: This test was stubbed out, because a dependency of openXC7 is unavailable on this platform")
      '';
}
