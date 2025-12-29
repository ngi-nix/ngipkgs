{ ... }:

{
  services.lemmy = {
    enable = true;
    ui.port = 3000;
    database.createLocally = true;
    settings = {
      hostname = "http://nixlemmy.com";
      port = 8000;
      setup = {
        admin_username = "admin";
        site_name = "Nix is Awesome Lemmy";
        admin_email = "lemmyadmin@example.com";
      };
    };
    adminPasswordFile = "/etc/lemmy-admin-password.txt";
    nginx.enable = true;
  };
}
