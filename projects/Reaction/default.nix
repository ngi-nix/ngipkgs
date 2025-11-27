{
  lib,
  pkgs,
  sources,
  ...
}@args:

{
  metadata = {
    summary = "A daemon that scans program outputs for repeated patterns, and takes action";
    subgrants = {
      Core = [ "Reaction" ];
    };
    links = {
      repo = {
        text = "Source repository";
        url = "https://framagit.org/ppom/reaction";
      };
      homepage = {
        text = "Homepage";
        url = "https://reaction.ppom.me";
      };
      docs = {
        text = "Usage examples";
        url = "https://reaction.ppom.me/filters/index.html";
      };
    };
  };

  nixos.modules.services = {
    reaction = {
      name = "Reaction";
      module = lib.moduleLocFromOptionString "services.reaction";
      examples.basic = {
        module = ./examples/basic.nix;
        description = ''
          A setup, where reaction is run as a dedicated reaction user (indicated by runAsRoot set to false)

          And permissions are explicitly given to the reaction user
            - to be allowed to read ssh journal logs (adding reaction user to systemd-journal group)
            - and allow changing firewall rules (adding CAP_NET_ADMIN previlige to reaciton systemd service)
        '';
        tests.basic.module = pkgs.nixosTests.reaction;
      };
    };
  };

  # firewall tests are not tied to an example
  nixos.tests.firewall.module = pkgs.nixosTests.reaction-firewall;

  nixos.demo.vm = {
    module = ./demo/module.nix;
    usage-instructions = [
      {
        instruction = ''
          Reaction is a very powerful rules based engine.

          A common usecase is to scan ssh and webserver logs, and to ban hosts that cause multiple authentication errors.

          An `example-ssh.jsonnet` file has been provided in the ngipkgs repository.

          It was copied from ''${pkgs.reaction}/share/examples/example.jsonnet and modified slightly for the purpose of showcasing the demo
        '';
      }
      {
        instruction = ''
          Run the demo vm, it runs an ssh server at port 10022, a user `nixos` with password `nixos` exists.

          Run `watch journalctl -u reaction --no-pager` inside the demo vm.
        '';
      }
      {
        instruction = ''
          Open a new terminal in your host system and run try this ssh command thrice.

          `ssh -p 10022 nixos@localhost -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null`

          Attempt login to the demo vm with wrong passwords thrice and see that you get banned.
        '';
      }
    ];
    tests.demo.module = pkgs.nixosTests.reaction;
  };
}
