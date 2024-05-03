{
  imports = [
    ../modules/common.nix
    ./hydra.nix
    ./hydra-proxy.nix
    ./hardware.nix
  ];

  networking.hostName = "makemake";

  #system.configurationRevision = self.rev
  #  or (throw "Cannot deploy from an unclean source tree!");

  nix.buildMachines = [
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

  fileSystems."/" = {
    device = "rpool/root";
    fsType = "zfs";
  };

  fileSystems."/boot" = {
    device = "/dev/disk/by-label/boot0";
    fsType = "ext4";
  };

  fileSystems."/postgres" = {
    device = "rpool/postgres";
    fsType = "zfs";
  };

  networking = {
    hostId = "5240310e";
    firewall.allowedTCPPorts = [80 443];
    firewall.allowPing = true;
    firewall.logRefusedConnections = true;
  };

  boot.loader.grub.devices = ["/dev/nvme0n1" "/dev/nvme1n1"];
  boot.loader.grub.copyKernels = true;

  users.extraUsers.root.openssh.authorizedKeys.keys = import ../ssh-keys.nix;
}
