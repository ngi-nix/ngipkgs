{ config, pkgs, ... }:
let
  port = 61812;
in
{
  services.misskey = {
    enable = true;

    settings = {
      url = "http://misskey.local";
      inherit port;
    };

    database.createLocally = true;
    redis.createLocally = true;
  };
}
