{
  config,
  pkgs,
  lib,
  ...
}:
with lib; {
  time.timeZone = "Europe/Amsterdam";

  users.mutableUsers = false;

  nix.settings = {
    sandbox = true;
    cores = 0;
    experimental-features = ["nix-command" "flakes"];
  };

  environment.systemPackages = [
    pkgs.emacs
    pkgs.git
    pkgs.gdb

    # jq is required by numtide/terraform-deploy-nixos-flakes.
    pkgs.jq
  ];

  services.sshd.enable = true;
}
