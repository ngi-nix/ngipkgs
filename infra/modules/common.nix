{pkgs, ...}: {
  time.timeZone = "Europe/Amsterdam";

  users.mutableUsers = false;

  nix.settings = {
    sandbox = true;
    cores = 0;
    experimental-features = ["nix-command" "flakes"];
  };

  environment.systemPackages = with pkgs; [
    emacs
    gdb
    git
    jq # required by numtide/terraform-deploy-nixos-flakes.
  ];

  services.sshd.enable = true;
}
