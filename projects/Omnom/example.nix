{ ... }:
{
  services.omnom = {
    enable = true;
    openFirewall = true;

    port = 8080;

    settings = {
      app = {
        disable_signup = true; # restrict CLI user-creation
        results_per_page = 50;
      };
      smtp = {
        tls = true;
        host = "127.0.0.1";
        port = 1025;
        username = "testUser";
      };
    };

    # Contains password for SMTP user
    passwordFile = "/etc/secrets/omnom.key";
  };
}
