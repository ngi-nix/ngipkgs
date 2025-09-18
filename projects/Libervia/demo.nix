{
  config,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.programs.libervia.kivy;

  xmppUsers = [
    "alice@example.org"
    "bob@example.org"
  ];
  xmppPassword = "foobar";
  setup-initial-libervia-user = pkgs.writeShellApplication {
    name = "setup-initial-libervia-user";
    runtimeInputs = with pkgs; [ prosody ];
    text = lib.strings.concatMapStringsSep "\n" (xmppUser: ''
      prosodyctl adduser ${xmppUser} <<EOF
      ${xmppPassword}
      ${xmppPassword}
      EOF
    '') xmppUsers;
  };

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
  config = lib.mkIf cfg.enable {
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
      httpFileShare = {
        domain = "upload.example.org";
      };
    };

    # Have example.org point to the local XMPP server
    networking.hosts."127.0.0.1" = [ "example.org" ];

    # Make the self-signed certificates work
    security.pki.certificateFiles = [ "${certs}/ca.crt" ];

    # Auto create Libervia XMPP users at system startup
    systemd.services.setup-libervia-prosody-users = {
      description = "Setup Libervia XMPP users";
      after = [ "prosody.service" ];
      wantedBy = [ "prosody.service" ];
      serviceConfig = {
        User = config.services.prosody.user;
        Type = "oneshot";
        Restart = "on-failure";
        RestartSec = "5s";
      };
      script = "${lib.getExe setup-initial-libervia-user}";
    };

    # Graphics
    services.xserver.enable = true;

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
      };
    };
  };
}
