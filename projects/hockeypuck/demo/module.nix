{
  pkgs,
  ...
}:
let
  servicePort = 11371;
in
{
  services.hockeypuck = {
    enable = true;
    port = servicePort;
  };

  services.postgresql = {
    enable = true;
    ensureDatabases = [ "hockeypuck" ];
    ensureUsers = [
      {
        name = "hockeypuck";
        ensureDBOwnership = true;
      }
    ];
  };

  environment.systemPackages = with pkgs; [
    gnupg
  ];

  # example gpg key
  environment.etc.gpg-key-foo.text = ''
    %echo Generating a basic OpenPGP key
    %no-protection
    Key-Type: DSA
    Key-Length: 1024
    Subkey-Type: ELG-E
    Subkey-Length: 1024
    Name-Real: Foo Example
    Name-Email: foo@example.org
    Expire-Date: 0
    # Do a commit here, so that we can later print "done"
    %commit
    %echo done
  '';

  networking.firewall.allowedTCPPorts = [ servicePort ];
}
