{
  config,
  pkgs,
  lib,
  ...
}:
let
  # Create two xmpp users: john and alice
  # used to login to Kaidan
  userJohn = "john@example.org";
  userAlice = "alice@example.org";
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

  # Configure Prosody with self-signed certificates
  services.prosody = {
    enable = true;
    admins = [ "root@example.org" ];
    virtualHosts."example.org" = {
      enabled = true;
      domain = "example.org";
      ssl.cert = "/etc/prosody/certs/example.org.crt";
      ssl.key = "/etc/prosody/certs/example.org.key";
    };
    muc = [ { domain = "conference.example.org"; } ];
    httpFileShare = {
      domain = "upload.example.org";
    };
    # Additional config to ensure certificates work
    extraConfig = ''
      -- Set certificate directory
      certificates = "/etc/prosody/certs"
    '';
  };

  networking.hosts."127.0.0.1" = [ "example.org" ];

  # Make the self-signed certificates work
  security.pki.certificateFiles = [ "${certs}/ca.crt" ];

  # Setup certificate directory for prosody
  systemd.services.prosody-cert-setup = {
    description = "Setup prosody certificate directory";
    before = [ "prosody.service" ];
    wantedBy = [ "prosody.service" ];
    serviceConfig = {
      Type = "oneshot";
      RemainAfterExit = true;
    };
    script = ''
      mkdir -p /etc/prosody/certs
      cp ${certs}/server.crt /etc/prosody/certs/example.org.crt
      cp ${certs}/server.key /etc/prosody/certs/example.org.key
      cp ${certs}/ca.crt /etc/prosody/certs/ca.crt
      chown -R prosody:prosody /etc/prosody/certs
      chmod 600 /etc/prosody/certs/*.key
      chmod 644 /etc/prosody/certs/*.crt
    '';
  };

  # Auto create Kaidan XMPP users at system startup
  systemd.services.setup-kaidan-prosody-users = {
    description = "Setup Kaidan XMPP users";
    after = [ "prosody.service" ];
    wantedBy = [ "prosody.service" ];
    serviceConfig = {
      User = config.services.prosody.user;
      Type = "oneshot";
      Restart = "on-failure";
      RestartSec = "5s";
    };
    script = "${setup-kaidan-prosody-users}/bin/setup-kaidan-prosody-users";
  };

  environment.systemPackages = with pkgs; [
    prosody
  ];
}
