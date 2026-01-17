{
  lib,
  pkgs,
  sources,
  ...
}@args:

{
  metadata = {
    summary = "Remote sharing of terminal sessions";
    subgrants = {
      Core = [
        "Tau"
      ];
    };
    # Top-level links for things that are in common across the whole project (mandatory)
    links = {
      repo = {
        text = "Source repository";
        url = "https://github.com/tau-org";
      };
      homepage = null;
      docs = null;
    };
  };

  nixos.modules.programs = {
    tau-radio = {
      module = ./programs/tau-radio/module.nix;
      examples."Enable tau-radio" = {
        module = ./programs/tau-radio/examples/basic.nix;
        # FIX: device audio in NixOS VM
        tests.client.module = ./services/tau-tower/tests/basic.nix;
        tests.client.problem.broken.reason = ''
          The test only works interactively, given it needs access to the device's microphone, which isn't available in a non-interactive VM.

          To test this, remove `tests.client.problem.broken.reason` and run:

          ```
          nix run .#checks.x86_64-linux.projects/Tau/nixos/tests/client.driverInteractive -L
          ```
        '';
      };
      links.repo = {
        text = "Source repository";
        url = "https://github.com/tau-org/tau-radio";
      };
    };
  };

  nixos.modules.services = {
    tau-tower = {
      module = ./services/tau-tower/module.nix;
      examples."Enable tau-tower" = {
        module = ./services/tau-tower/examples/basic.nix;
        # FIX: device audio in NixOS VM
        tests.server.module = ./services/tau-tower/tests/basic.nix;
        tests.server.problem.broken.reason = ''
          The test only works interactively, given it needs access to the device's microphone, which isn't available in a non-interactive VM.

          To test this, remove `tests.server.problem.broken.reason` and run:

          ```
          nix run .#checks.x86_64-linux.projects/Tau/nixos/tests/server.driverInteractive -L
          ```
        '';
      };
      links.repo = {
        text = "Source repository";
        url = "https://github.com/tau-org/tau-tower";
      };
    };
  };
}
