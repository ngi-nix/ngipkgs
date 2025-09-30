{ pkgs, ... }:

{
  programs.tau-radio = {
    enable = true;
    settings = {
      username = "alice";
    };
    # WARN: Don't use this in production as it will copy the file to the
    # Nix store. Instead, provide a string that contains an absolute path
    # to a file that already exists on disk.
    passwordFile = pkgs.writeText "password.txt" "superSecretPassword";
  };
}
