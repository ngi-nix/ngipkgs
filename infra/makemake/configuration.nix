{
  pkgs,
  lib,
  ...
}: {
  imports = [
    ./buildbot.nix
    ./hardware.nix
    ./sops.nix
  ];

  networking.hostName = "makemake";

  nix = {
    buildMachines = [
      {
        hostName = "localhost";
        systems = ["x86_64-linux" "i686-linux"];
        maxJobs = 16;
        speedFactor = 1;
        supportedFeatures = [
          "nixos-test"
          "benchmark"
          "big-parallel"
          "kvm"
          "ca-derivations"
        ];
      }
    ];
    gc = {
      automatic = true;
      dates = "weekly";
      options = "--delete-older-than 7d";
    };
    settings = {
      min-free = let GiB = 1024 * 1024 * 1024; in 4 * GiB;
      max-jobs = lib.mkDefault 16;
      allowed-uris = "https://github.com/ https://git.savannah.gnu.org/ github: gitlab: git+https:";
      cores = 0;
      experimental-features = ["nix-command" "flakes" "ca-derivations"];
      sandbox = true;
    };
  };

  time.timeZone = "Europe/Amsterdam";

  users = {
    mutableUsers = false;
    users.root.openssh.authorizedKeys.keys = import ../ssh-keys.nix;
  };

  environment.systemPackages = with pkgs; [
    emacs
    gdb
    git
    jq # required by numtide/terraform-deploy-nixos-flakes.
  ];

  services = {
    caddy = {
      enable = true;
      email = "ngi@nixos.org";
    };
    openssh = {
      enable = true;
      settings.PasswordAuthentication = false;
    };
  };

  fileSystems = {
    "/" = {
      device = "rpool/root";
      fsType = "zfs";
    };
    "/boot" = {
      device = "/dev/disk/by-label/boot0";
      fsType = "ext4";
    };
    "/postgres" = {
      device = "rpool/postgres";
      fsType = "zfs";
    };
  };

  networking = {
    hostId = "5240310e";
    firewall.allowedTCPPorts = [80 443];
    firewall.allowPing = true;
    firewall.logRefusedConnections = true;
  };

  boot.loader.grub = {
    devices = ["/dev/nvme0n1" "/dev/nvme1n1"];
    copyKernels = true;
  };
}
