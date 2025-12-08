{
  config,
  pkgs,
  lib,
  ...
}:
let
  cfg = config.programs.kaidan;

  cert =
    pkgs:
    pkgs.runCommand "selfSignedCerts" { buildInputs = [ pkgs.openssl ]; } ''
      openssl req -x509 -newkey rsa:4096 -keyout key.pem -out cert.pem -nodes -days 365 \
        -subj '/C=GB/CN=example.com/CN=uploads.example.com/CN=conference.example.com' -addext "subjectAltName = DNS:example.com,DNS:uploads.example.com,DNS:conference.example.com"
      mkdir -p $out
      cp key.pem cert.pem $out
    '';

  # Creates and set password for the 2 xmpp test users.
  #
  # Doing that in a bash script instead of doing that in the test
  # script allow us to easily provision the users when running that
  # test interactively.
  createUsers =
    pkgs:
    pkgs.writeShellScriptBin "create-prosody-users" ''
      set -e
      prosodyctl register alice example.com foobar
      prosodyctl register john example.com foobar
    '';

  # Deletes the test users.
  delUsers =
    pkgs:
    pkgs.writeShellScriptBin "delete-prosody-users" ''
      set -e
      prosodyctl deluser alice@example.com
      prosodyctl deluser john@example.com
    '';
in
{
  config = lib.mkIf cfg.enable {
    # Make the self-signed certificates work
    security.pki.certificateFiles = [ "${cert pkgs}/cert.pem" ];

    networking.extraHosts = ''
      ${config.networking.primaryIPAddress} example.com
      ${config.networking.primaryIPAddress} conference.example.com
      ${config.networking.primaryIPAddress} uploads.example.com
    '';

    environment.systemPackages = [
      (createUsers pkgs)
      (delUsers pkgs)
    ];

    # Configure Prosody with self-signed certificates
    services.prosody = {
      enable = true;
      ssl.cert = "${cert pkgs}/cert.pem";
      ssl.key = "${cert pkgs}/key.pem";
      virtualHosts.example = {
        enabled = true;
        domain = "example.com";
        ssl.cert = "${cert pkgs}/cert.pem";
        ssl.key = "${cert pkgs}/key.pem";
      };
      muc = [ { domain = "conference.example.com"; } ];
      httpFileShare = {
        domain = "uploads.example.com";
      };
    };

    networking.hosts."127.0.0.1" = [ "example.com" ];

    # Prosody requires a keyring for storing user passwords
    services.gnome.gnome-keyring.enable = true;
  };
}
