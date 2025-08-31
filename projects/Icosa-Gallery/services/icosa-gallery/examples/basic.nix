{ pkgs, ... }:

{
  services.icosa-gallery = {
    enable = true;
    enableLocalDB = true;
    settings = {
      # Do *NOT* do this in production!
      POSTGRES_PASSWORD = "icosa-gallery";
      DJANGO_SECRET_KEY = "g3tu0@_-fvhdn&p09mv)x9+x6^7q58&&r9l*k61k-m2f72j&z";
      JWT_SECRET_KEY = "sd2k+@tt0x22_))w9wtv(h1278bc#mkd7jna5nannws(4vr^7";

      DJANGO_DISABLE_CACHE = "1";
      DEPLOYMENT_NO_SSL = "1";
      DEPLOYMENT_ENV = "local";
    };
  };

  # Do *NOT* do this in production!
  services.postgresql.initialScript = pkgs.writeText "init-sql-script" ''
    CREATE ROLE "icosa-gallery" LOGIN PASSWORD 'icosa-gallery';
  '';
}
