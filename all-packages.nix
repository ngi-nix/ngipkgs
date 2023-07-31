{newScope, ...}: let
  self = rec {
    libgnunetchat = callPackage ./pkgs/libgnunetchat {};
    gnunet-messenger-cli = callPackage ./pkgs/gnunet-messenger-cli {};
    liberaforms = callPackage ./pkgs/liberaforms {};
    liberaforms-env = callPackage ./pkgs/liberaforms/env.nix {};
    pretalx-mysql = callPackage ./pkgs/pretalx { withMysql = true; withRedis=true;};
    pretalx-postgresql = callPackage ./pkgs/pretalx { withPostgresql = true; withRedis=true;};
    pretalx = callPackage ./pkgs/pretalx { 
      withMysql = true;
      withPostgresql = true;
      withRedis = true;
      withTest = true;
    };
  };

  callPackage = newScope self;
in
  self
