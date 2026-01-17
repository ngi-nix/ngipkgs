{
  lib,
  pkgs,
  sources,
  ...
}@args:
{
  metadata = {
    summary = ''
      Libervia is a multi-frontend, multi-purpose XMPP client. It doesn't just
      focus on instant messaging, and uses the open standard to provide features
      such as blogging/microblogging, calendar events, file sharing, end-to-end
      encryption, etc.
    '';
    subgrants.Review = [
      "Libervia"
      "Libervia-AV"
    ];
  };
  nixos = {
    modules.programs.libervia = {
      links = {
        config = {
          text = "libervia.conf file reference";
          url = "https://libervia.org/__b/doc/backend/configuration.html";
        };
        backend = {
          text = "Documentation on how to manually start the backend";
          url = "https://libervia.org/__b/doc/backend/installation.html#usage";
        };
        cli = {
          text = "Command-line interface documentation";
          url = "https://libervia.org/__b/doc/backend/libervia-cli/index.html";
        };
        kivy = {
          text = "Kivy desktop client documentation";
          url = "https://libervia.org/documentation/desktop-mobile";
        };
      };
      module = ./module.nix;
      examples = {
        backend = {
          description = "Enables manually starting Libervia's backend and the use of its CLI and TUI clients.";
          module = ./examples/backend.nix;
          tests.backend = {
            module = ./tests/backend.nix;
          };
        };
        desktop = {
          description = "Enables the use of the Kivy desktop client for Libervia.";
          module = ./examples/desktop.nix;
          # FIX:
          tests.desktop = {
            module = ./tests/desktop.nix;
          };
        };
      };
    };

    demo.vm = {
      module = ./examples/desktop.nix;
      module-demo = ./demo.nix;
      tests.demo.module = ./tests/desktop.nix;
      usage-instructions = [
        {
          instruction = ''
            Once the graphical desktop has loaded, navigate to and click:

            `iceWM` (in the bottom-left of the desktop) -> `Network` -> `Libervia Desktop (Cagou) [Chat]`

            Give the client some time to load.
          '';
        }
        {
          instruction = ''
            Once it has fully loaded, you need to create a new profile and enter some details. Use whichever name you want.

            - If you have an existing XMPP account, enter your JID and password
            - If you don't already have an XMPP account and just want to test the client, a local XMPP server has been
              set up with the following user:
              - JID: alice@example.org
              - Password: foobar
          '';
        }
        {
          instruction = ''
            Once the profile is created, select it in the list and click on "Connect".
          '';
        }
        {
          instruction = ''
            You can now try out Libervia's Kivy desktop client.
          '';
        }
        {
          instruction = ''
            For testing communication between two users, you may repeat the process for adding a profile, and use the
            following credentials:

            - JID: bob@example.org
            - Password: foobar
          '';
        }
      ];
    };
  };
}
