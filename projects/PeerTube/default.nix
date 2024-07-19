{
  pkgs,
  lib,
  sources,
} @ args: {
  packages = {
    inherit (pkgs) peertube-plugin-akismet peertube-plugin-auth-ldap peertube-plugin-auth-openid-connect peertube-plugin-auth-saml2 peertube-plugin-auto-block-videos peertube-plugin-auto-mute peertube-plugin-hello-world peertube-plugin-logo-framasoft peertube-plugin-matomo peertube-plugin-privacy-remover peertube-plugin-transcoding-custom-quality peertube-plugin-transcoding-profile-debug peertube-plugin-video-annotation peertube-theme-background-red peertube-theme-dark peertube-theme-framasoft peertube-plugin-livechat;
  };
  nixos = {
    modules.services.peertube.plugins = ./module.nix;
    tests.peertube-plugins = import ./test.nix args;
    examples = {
      base = {
        description = "Basic configuration, mainly used for testing purposes.";
        path = ./example.nix;
      };
    };
  };
}
