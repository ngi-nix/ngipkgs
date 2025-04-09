{
  lib,
  pkgs,
  sources,
}@args:
{
  metadata = {
    summary = ''
      Libervia is a multi-frontend, multi-purpose XMPP client. It doesn't just
      focus on instant messaging, and uses the open standard to provide features
      such as blogging/microblogging, calendar events, file sharing, end-to-end
      encryption, etc.
    '';
    subgrants = [
      "Libervia"
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
          tests.backend = import ./tests/backend.nix args;
        };
        desktop = {
          description = "Enables the use of the Kivy desktop client for Libervia.";
          module = ./examples/desktop.nix;
          tests.desktop = import ./tests/desktop.nix args;
        };
      };
    };
  };
}
