{newScope, ...}: let
  self = rec {
    flarum = callPackage ./pkgs/flarum {};
    gnunet-messenger-cli = callPackage ./pkgs/gnunet-messenger-cli {};
    kikit = callPackage ./pkgs/kikit {};
    lcrq = callPackage ./pkgs/lcrq {};
    lcsync = callPackage ./pkgs/lcsync {inherit lcrq librecast;};
    liberaforms = callPackage ./pkgs/liberaforms {};
    liberaforms-env = callPackage ./pkgs/liberaforms/env.nix {};
    libgnunetchat = callPackage ./pkgs/libgnunetchat {};
    librecast = callPackage ./pkgs/librecast {inherit lcrq;};
    pretalx-mysql = callPackage ./pkgs/pretalx { withMysql = true; withRedis=true;};
    pretalx-postgresql = callPackage ./pkgs/pretalx { withPostgresql = true; withRedis=true;};
    pretalx = callPackage ./pkgs/pretalx { 
      withMysql = true;
      withPostgresql = true;
      withRedis = true;
      withTest = true;
    };
  };

  nixpkgs-candidates = {
    pcbnew-transition = callPackage ./nixpkgs-candidates/pcbnew-transition {};
    pybars3 = callPackage ./nixpkgs-candidates/pybars3 {};
    pymeta3 = callPackage ./nixpkgs-candidates/pymeta3 {};
    euclid3 = callPackage ./nixpkgs-candidates/euclid3 {};
  };

  callPackage = newScope (self // nixpkgs-candidates // {inherit callPackage;});
in
  self
