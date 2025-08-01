{
  sources,
  pkgs,
  lib,
  ...
}:
{
  name = "kaidan";

  nodes = {
    machine =
      {
        pkgs,
        ...
      }:
      {
        imports = [
          sources.modules.ngipkgs
          sources.modules.programs.kaidan
          sources.examples.Kaidan."Kaidan with local XMPP server and self-signed certs"
        ];

        environment.systemPackages = with pkgs; [
          xdotool
        ];

      };
  };

  enableOCR = true;

  testScript =
    { nodes, ... }:
    let
      userJohn = "john@example.org";
      userAlice = "alice@example.org";
      textAlice = "Hello Alice!";
      textJohn = "Hello John!";
      xmppPassword = "foobar";
      setup-kaidan-prosody-users = pkgs.writeShellApplication {
        name = "setup-kaidan-prosody-users";
        runtimeInputs = with pkgs; [ prosody ];
        text = ''
          prosodyctl adduser ${userJohn} <<EOF
          ${xmppPassword}
          ${xmppPassword}
          EOF

          # Add second user for sending messages to
          # This is needed because Kaidan does not support self-messaging
          prosodyctl adduser ${userAlice} <<EOF
          ${xmppPassword}
          ${xmppPassword}
          EOF
        '';
      };
    in
    ''
      def login_user(user):
        machine.send_chars(f"{user}\n", 0.1)
        machine.sleep(1)
        machine.send_chars("${xmppPassword}\n", 0.1)

      # add user to the contact list
      def add_contact(user):
        machine.succeed("xdotool mousemove 26 48 click 1")
        machine.sleep(1)

        machine.succeed("xdotool mousemove 26 48 click 1")
        machine.succeed("xdotool mousemove 110 239 click 1")
        machine.sleep(1)

        machine.send_chars(f"{user}\n",0.1);
        machine.sleep(1)

        machine.succeed("xdotool mousemove 501 551 click 1")

      # logout current user
      def logout_user():
        machine.succeed("xdotool mousemove 26 48 click 1")
        machine.succeed("xdotool mousemove 96 95 click 1")
        machine.sleep(3)
        machine.succeed("xdotool mousemove 485 675 click --repeat 40 5")
        machine.sleep(3)
        machine.succeed("xdotool mousemove 462 552 click 1")
        machine.sleep(1)
        machine.succeed("xdotool mousemove 463 612 click 1")
        machine.sleep(1)

      # send a text
      def send_text(text):
        machine.send_chars(f"{text}\n", 0.2)

      start_all()
      machine.wait_for_x()

      # Setup prosody so we can connect
      machine.wait_for_console_text("Started Prosody XMPP server")
      machine.succeed("${lib.getExe setup-kaidan-prosody-users}")

      # Start Kaidan and scale it to full screen
      machine.execute("kaidan >&2 &")
      machine.wait_for_text("free communication")
      machine.send_key("alt-f10")

      machine.sleep(1)

      login_user("${userJohn}")

      machine.wait_for_text("Select a chat")

      add_contact("${userAlice}")

      machine.sleep(1)
      machine.wait_for_text("No messages yet")

      # john sends alice a message and logs out
      send_text("${textAlice}")
      machine.sleep(4)
      logout_user()
      machine.sleep(5)

      # alice logs in sends back a message to john
      login_user("${userAlice}")
      machine.wait_for_text("Hello Alice!")
      machine.succeed("xdotool mousemove 146 99 click 1")

      machine.sleep(1)
      machine.send_key("tab")
      machine.sleep(1)
      send_text("${textJohn}")
      machine.sleep(3)

      # alice logs out and john logs back in
      logout_user()
      machine.sleep(20)
      login_user("${userJohn}")
      machine.sleep(3)

      # john should see alice's message
      machine.succeed("xdotool mousemove 146 99 click 1")
      machine.sleep(2)
      machine.wait_for_text("${textJohn}")
    '';
}
