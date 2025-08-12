{
  lib,
  pkgs,
  sources,
  ...
}@args:

{
  metadata = {
    summary = "Cross-platform chat client for the XMPP protocol";
    subgrants = [
      "Kaidan"
      "Kaidan-Groups"
      "Kaidan-AV"
      "Kaidan-Auth"
      "Kaidan-Mediasharing"
      "Kaidan-MUC"
    ];
    links = {
      install = {
        text = "Build Kaidan from source";
        url = "https://invent.kde.org/network/kaidan/-/wikis/building/linux-debian-based";
      };
      source = {
        text = "Git repository";
        url = "https://invent.kde.org/network/kaidan";
      };
    };
  };

  nixos.modules.programs = {
    kaidan = {
      module = ./programs/kaidan/module.nix;
      examples."Kaidan with local XMPP server and self-signed certs" = {
        module = ./programs/kaidan/examples/demo.nix;
        description = "Kaidan example with local XMPP Server";
        tests.kaidan.module = import ./programs/kaidan/tests/kaidan.nix args;
        tests.kaidan.problem.broken.reason = ''
          Prosody hangs for a long time:

          https://buildbot.ngi.nixos.org/#/builders/1231/builds/1/steps/1/logs/stdio

          Investigate why and fix it.
        '';
      };
    };
  };

  nixos.demo.vm = {
    module = ./programs/kaidan/examples/demo.nix;
    tests.demo.module = import ./programs/kaidan/tests/kaidan.nix args;
    tests.demo.problem.broken.reason = ''
      Prosody hangs for a long time:

      https://buildbot.ngi.nixos.org/#/builders/1231/builds/1/steps/1/logs/stdio

      Investigate why and fix it.
    '';
    description = ''
      Once the graphical environment is running, open Kaidan from Menu > Network.

      Right-click on its entry on the window bar and choose "Maximize Alt+f10" to fit the Kaidan window to the screen size.

      NOTE: You need an XMPP user account to use Kaidan.
      If you have an account, use that to login and you should be able to send/receive a message.

      If you don't have one, two demo-user accounts, `alice` and `john`, are available.

      Login as the first user:
      - Chat address: `john@example.org`
      - Password: `foobar`

      When logged in, choose "add contact by chat address" on the hamburger menu.
      Add `alice@example.com`, and a chat will be started. Send a message to `alice`.

      You can verify that `alice` has received the message by logging out `john` and logging in as `alice`
      - Chat address: `alice@example.org`
      - Password: `foobar`
    '';
  };
}
