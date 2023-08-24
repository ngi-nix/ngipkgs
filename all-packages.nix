{newScope, ...}: let
  self = rec {
    flarum = callPackage ./pkgs/flarum {};
    gnunet-messenger-cli = callPackage ./pkgs/gnunet-messenger-cli {};
    kikit = callPackage ./pkgs/kikit {};
    lcrq = callPackage ./pkgs/lcrq {};
    lcsync = callPackage ./pkgs/lcsync {inherit lcrq librecast;};

    # LiberaForms is intentionally disabled.
    # Refer to <https://github.com/ngi-nix/ngipkgs/issues/40>.
    #liberaforms = callPackage ./pkgs/liberaforms {};
    #liberaforms-env = callPackage ./pkgs/liberaforms/env.nix {};

    libgnunetchat = callPackage ./pkgs/libgnunetchat {};
    librecast = callPackage ./pkgs/librecast {inherit lcrq;};
    pretalx-mysql = callPackage ./pkgs/pretalx {
      withPlugins = true;
      withMysql = true;
      withRedis = true;
    };
    pretalx-postgresql = callPackage ./pkgs/pretalx {
      withPlugins = true;
      withPostgresql = true;
      withRedis = true;
    };
    pretalx = callPackage ./pkgs/pretalx {
      withPlugins = true;
      withMysql = true;
      withPostgresql = true;
      withRedis = true;
      withTest = true;
    };
    rosenpass = callPackage ./pkgs/rosenpass {};
    rosenpass-tools = callPackage ./pkgs/rosenpass-tools {};
  };

  nixpkgs-candidates = {
    # Attempting to upstream to nixpkgs here: https://github.com/NixOS/nixpkgs/pull/249464
    pcbnew-transition = callPackage ./nixpkgs-candidates/pcbnew-transition {};
    # Attempting to upstream to nixpkgs here: https://github.com/NixOS/nixpkgs/pull/249464
    pybars3 = callPackage ./nixpkgs-candidates/pybars3 {};
    # Attempting to upstream to nixpkgs here: https://github.com/NixOS/nixpkgs/pull/249464
    pymeta3 = callPackage ./nixpkgs-candidates/pymeta3 {};
    # Attempting to upstream to nixpkgs here: https://github.com/NixOS/nixpkgs/pull/249464
    euclid3 = callPackage ./nixpkgs-candidates/euclid3 {};
  };

  callPackage = newScope (self // nixpkgs-candidates // {inherit callPackage;});
in
  self
