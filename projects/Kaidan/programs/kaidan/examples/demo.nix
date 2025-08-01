{
  pkgs,
  lib,
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

  programs.kaidan.enable = true;

  virtualisation.graphics = lib.mkForce true;

  services.xserver = {
    enable = true;
    displayManager.lightdm.enable = true;
  };
  services.displayManager.autoLogin = {
    enable = true;
    user = "root";
  };
  # Use IceWM as the window manager.
  # Don't use a desktop manager.
  services.displayManager.defaultSession = lib.mkDefault "none+icewm";
  services.xserver.windowManager.icewm.enable = true;

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
}
