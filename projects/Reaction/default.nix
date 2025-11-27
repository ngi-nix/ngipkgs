{
  lib,
  pkgs,
  sources,
  ...
}@args:

{
  metadata = {
    summary = "Daemon that scans program outputs for repeated patterns, and takes action";
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
      module = ./services/reaction/module.nix;
      examples.non-root = {
        module = ./services/reaction/examples/non-root.nix;
        description = ''
          A setup, where reaction is run as a dedicated reaction user (indicated by runAsRoot set to false)

          And permissions are explicitly given to the reaction user
            - to be allowed to read ssh journal logs (adding reaction user to systemd-journal group)
            - and allow changing firewall rules (adding CAP_NET_ADMIN previlige to reaciton systemd service)
        '';
        tests.non-root.module = pkgs.nixosTests.reaction;
      };
      examples.root = {
        module = ./services/reaction/examples/root.nix;
        description = ''
          A setup, where reaction is run as root giving it full access

          Prefer the non-root configuration and give the service and the reaction user fine-grained access based on your usecase for reaction.
        '';
        tests.root.module = pkgs.nixosTests.reaction-firewall;
      };
    };
  };

  nixos.demo.vm = {
    module = ./demo/module.nix;
    usage-instructions = [
      {
        instruction = ''
          Reaction is a very powerful rules based engine.

          A common usecase is to scan ssh and webserver logs, and to ban hosts that cause multiple authentication errors.

          Provide a configuration file for reaction, for example: [`example.jsonnet`](https://framagit.org/ppom/reaction/-/blob/2095009fa96cc734eaa10bda23764dbad93c520a/config/example.jsonnet).
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

          Attempt login to the demo vm with wrong passwords twice.
        '';
      }
      {
        instruction = ''
          Go back to the demo vm terminal, and notice that you've been banned in the last line.
        '';
      }
    ];
    tests.demo.module = pkgs.nixosTests.reaction-firewall;
  };
}
