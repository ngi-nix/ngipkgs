{ ... }:
{
  services = {
    galene = {
      enable = true;

      port = 8443;

      tls = {
        enable = true;
        certificatePath = "Path/"
        keyfile = "keyfile.pem"
      };

      users = {
        username = "admin"
        password = "pass"
        admin = true;
      };
    };
  }
}
