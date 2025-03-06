{
  sources,
  lib,
  pkgs,
  ...
}:
let
  xmppUser = "alice";
  xmppId = "${xmppUser}@example.org";
  xmppPassword = "foobar";
  xmppMessage = "This is a test message.";
  setup-initial-libervia-user = pkgs.writeShellApplication {
    name = "setup-initial-libervia-user";
    runtimeInputs = with pkgs; [ prosody ];
    text = ''
      exec prosodyctl adduser ${xmppId} <<EOF
      ${xmppPassword}
      ${xmppPassword}
      EOF
    '';
  };
in
{
  name = "libervia";

  nodes = {
    server =
      {
        config,
        lib,
        pkgs,
        ...
      }:
      let
        # We need a CA-signed certificate to establish a TLS connection with prosody
        # And the CA certificate needs to be allowed globally
        # Code taken from <nixpkgs>/nixos/tests/custom-ca.nix
        certs =
          let
            caName = "Libervia CA";
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
          sources.modules.programs.libervia
          sources.examples.Libervia.base
          # can't test Libervia/unfree, enabling unfree derivations breaks nixosTests eval
        ];

        # Need an actual logged-in user to test with
        users.users.alice = {
          description = "Alice Foobar";
          password = "foobar";
          isNormalUser = true;
          extraGroups = [ "wheel" ];
          uid = 1000;
        };

        # Need a graphical session because we need to launch multiple programs in a valid D-Bus session
        services.xserver = {
          enable = true;
          displayManager.lightdm.enable = true;
          windowManager.icewm.enable = true;
        };

        # Automatic log-in
        services.displayManager = {
          defaultSession = "none+icewm";
          autoLogin = {
            enable = true;
            user = "alice";
          };
        };

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

        environment = {
          etc = {
            # Setup some defaults to better point it at local prosody
            # This is *not* regular INI format afaict, can't use generator
            "libervia.conf".text = ''
              [DEFAULT]
              xmpp_domain = example.org
              hosts_dict = {
                  "example.org": {"host": "127.0.0.1"}
                  }
            '';

            # Input for message sending command
            "xmppMessage".text = xmppMessage;
          };

          # Small script to register our test user in prosody
          systemPackages = [
            setup-initial-libervia-user
            pkgs.firefox
            pkgs.xdotool
          ];
        };
      };
  };

  # Need to see when terminals have launched
  enableOCR = true;

  testScript =
    { nodes, ... }:
    ''
      # Need a terminal to run stuff, need D-Bus session
      def spawn_terminal():
          machine.send_key("ctrl-alt-t")
          # Can't reliably OCR for this at default size. sleep, adjust & check later
          machine.sleep(10)
          machine.send_key("alt-f10")
          # Increase font size to help with OCR
          machine.send_key("shift-kp_add")
          machine.send_key("shift-kp_add")
          machine.send_key("shift-kp_add")
          machine.send_key("shift-kp_add")
          # Now check if we can see it
          machine.wait_for_text("alice")

      # Next workspace
      def next_workspace():
          machine.send_key("ctrl-alt-right")
          machine.sleep(2) # Make sure we're actually on the next workspace

      start_all()

      machine.wait_for_x()
      machine.wait_for_file("/home/alice/.Xauthority")

      # Setup prosody so we can connect
      machine.wait_for_console_text("Started Prosody XMPP server")
      machine.succeed("sudo -su prosody ${lib.getExe setup-initial-libervia-user}")

      # We use in-session terminals for running commands, but relying on OCR to view results is slow
      # Create some output files for commands to pipe outputs into
      # And start listeners that throw the data into the console for quicker results
      machine.succeed("sudo -su alice touch /home/alice/backend.log")
      machine.succeed("sudo -su alice tail -f /home/alice/backend.log >&2 &")
      machine.succeed("sudo -su alice touch /home/alice/frontend.log")
      machine.succeed("sudo -su alice tail -f /home/alice/frontend.log >&2 &")
      machine.succeed("sudo -su alice touch /home/alice/desktop.log")
      machine.succeed("sudo -su alice tail -f /home/alice/desktop.log >&2 &")

      with subtest("libervia-backend works"):
          # Start libervia backend in foreground, so we can read logs
          spawn_terminal()
          machine.send_chars("libervia-backend fg | tee -a ~/backend.log\n")
          machine.wait_for_console_text("Backend is ready")

      next_workspace()

      with subtest("libervia CLI works"):
          # Register profile with setup XMPP account in Libervia
          spawn_terminal()
          machine.send_chars("libervia-cli profile create -j ${xmppId} -x ${xmppPassword} alice | tee -a ~/frontend.log\n")
          machine.wait_for_console_text(r"\[${xmppUser}\] Profile session started")

          # Log in
          machine.send_chars("libervia-cli profile connect -p alice -c | tee -a ~/frontend.log\n")
          machine.wait_for_console_text("Data consistency ensured/restored.")

          # Send something
          machine.send_chars("libervia-cli message send ${xmppId} </etc/xmppMessage | tee -a ~/frontend.log\n")
          machine.wait_for_console_text("${xmppUser} has 1 items")

          # Check if we can query the message
          machine.send_chars("libervia-cli message mam | tee -a ~/frontend.log\n")
          machine.wait_for_console_text("${xmppUser}> ${xmppMessage}") # first log, us sending the message to ourself
          machine.wait_for_console_text("${xmppUser}> ${xmppMessage}") # second log, us receicing the message from ourself

      next_workspace()

      with subtest("libervia-desktop-kivy works"):
          # Start it
          spawn_terminal()
          machine.send_chars("libervia-desktop-kivy 2>&1 | tee -a ~/desktop.log\n")
          machine.wait_for_text("Select a profile")
          machine.send_key("alt-f10")

          # Log in as alice
          machine.succeed("sudo -su alice xdotool mousemove 518 163 click 1")
          machine.sleep(2)
          machine.succeed("sudo -su alice xdotool mousemove 509 721 click 1")
          machine.wait_for_text("chat")

          # Enter chat
          machine.succeed("sudo -su alice xdotool mousemove 493 199 click 1")
          machine.wait_for_text("Your contacts")

          # Open conversation with ourselves
          machine.succeed("sudo -su alice xdotool mousemove 80 148 click 1")
          machine.wait_for_text("${xmppMessage}")
    '';
}
