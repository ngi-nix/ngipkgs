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
      let
        # We need a CA-signed certificate to establish a TLS connection with prosody
        # And the CA certificate needs to be allowed globally
        # Code taken from <nixpkgs>/nixos/tests/custom-ca.nix
        certs =
          let
            caName = "Kaidan CA";
            domain = "example.org";
          in
          pkgs.runCommand "example-cert" { buildInputs = [ pkgs.gnutls ]; } ''
            mkdir $out

            # CA cert template
            cat >ca.template <<EOF
            organization = "${caName}"
            cn = "${caName}"
            expiration_days = 365
            ca
            cert_signing_key
            crl_signing_key
            EOF

            # server cert template
            cat >server.template <<EOF
            organization = "An example company"
            cn = "${domain}"
            expiration_days = 30
            dns_name = "${domain}"
            encryption_key
            signing_key
            EOF

            # generate CA keypair
            certtool                \
              --generate-privkey    \
              --key-type rsa        \
              --sec-param High      \
              --outfile $out/ca.key
            certtool                     \
              --generate-self-signed     \
              --load-privkey $out/ca.key \
              --template ca.template     \
              --outfile $out/ca.crt

            # generate server keypair
            certtool                    \
              --generate-privkey        \
              --key-type rsa            \
              --sec-param High          \
              --outfile $out/server.key
            certtool                            \
              --generate-certificate            \
              --load-privkey $out/server.key    \
              --load-ca-privkey $out/ca.key     \
              --load-ca-certificate $out/ca.crt \
              --template server.template        \
              --outfile $out/server.crt
          '';
      in
      {
        imports = [
          sources.modules.ngipkgs
          sources.modules.programs.kaidan
          sources.examples.Kaidan.basic
          # sets up x11 with autologin
          "${sources.inputs.nixpkgs}/nixos/tests/common/x11.nix"
        ];

        # Local XMPP server to test against
        services.prosody = {
          enable = true;
          admins = [ "root@example.org" ];
          ssl.cert = "${certs}/server.crt";
          ssl.key = "${certs}/server.key";
          virtualHosts."example.org" = {
            enabled = true;
            domain = "example.org";
            ssl.cert = "${certs}/server.crt";
            ssl.key = "${certs}/server.key";
          };
          muc = [ { domain = "conference.example.org"; } ];
          uploadHttp = {
            domain = "upload.example.org";
          };
        };

        # Have example.org point to the local XMPP server
        networking.hosts."127.0.0.1" = [ "example.org" ];

        # Make the self-signed certificates work
        security.pki.certificateFiles = [ "${certs}/ca.crt" ];

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
