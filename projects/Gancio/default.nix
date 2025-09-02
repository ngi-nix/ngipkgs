{
  pkgs,
  lib,
  sources,
  ...
}@args:
{
  metadata = {
    summary = "Shared agenda for local communities that supports Activity Pub";
    subgrants.Core = [
      "Gancio"
    ];
  };
  nixos.modules.services = {
    gancio = {
      module = lib.moduleLocFromOptionString "services.gancio";
      examples."Enable Gancio" = {
        module = ./example.nix;
        tests.gancio.module = pkgs.nixosTests.gancio;
      };
    };
  };

  nixos.demo.vm = {
    module = ./demo/module.nix;
    module-demo = ./demo/module-demo.nix;
    description = "Deployment for demo purposes";
    tests.gancio.module = pkgs.nixosTests.gancio;
    usage-instructions = [
      {
        instruction = ''
          Inside the VM, create an admin account:

          ```
          $ cd /var/lib/gancio
          $ sudo -u gancio gancio users create admin secret admin
          ```
        '';
      }
      {
        instruction = ''
          In your host machine, open Gancio [in your browser](http://localhost:18000):

          ```
          $ open http://localhost:18000
          ```

          It may take a moment until it becomes accessible.
        '';
      }
      {
        instruction = ''
          Log in with the admin account:

          - **E-mail**: admin
          - **Password**: secret
        '';
      }
      {
        instruction = ''
          Add a new event.
        '';
      }
    ];
  };
}
