{
  pkgs,
  lib,
  ...
}:
{
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
        systems = [
          "x86_64-linux"
          "i686-linux"
        ];
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
      min-free =
        let
          GiB = 1024 * 1024 * 1024;
        in
        4 * GiB;
      max-jobs = lib.mkDefault 4;
      allowed-uris = "https://github.com/ https://git.savannah.gnu.org/ github: gitlab: git+https:";
      cores = 4;
      experimental-features = [
        "nix-command"
        "flakes"
        "ca-derivations"
      ];
      sandbox = true;
      trusted-users = [ "remotebuild" ];
    };
  };

  time.timeZone = "Europe/Amsterdam";

  users =
    let
      keys = with lib; mapAttrs (name: value: ./keys/${name}) (builtins.readDir ./keys);
      deploy = with keys; [ makemake ];
      infra = with keys; [
        hexa-gaia
        hexa-helix
        julienmalka
        vcunat
        zimbatm
      ];
      ngi = with keys; [
        fricklerhandwerk
        erethon
        lorenzleutgeb
      ];
      remotebuild = with keys; [
        getpsyched
        prince213
      ];
    in
    {
      mutableUsers = false;
      users.root.openssh.authorizedKeys.keyFiles = deploy ++ infra ++ ngi;
      users.remotebuild = {
        isNormalUser = true;
        createHome = false;
        group = "remotebuild";
        openssh.authorizedKeys.keyFiles = infra ++ ngi ++ remotebuild;
      };
      groups.remotebuild = { };
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
      virtualHosts."summer.nixos.org" = {
        extraConfig = ''
          redir /announcements/hiring-event https://nixos.org/blog/announcements/2021/2021-07-20-hiring-event permanent
          redir /announcements/summer-of-nix-2021-report https://nixos.org/blog/announcements/2022/2022-02-23-summer-of-nix-2021-report permanent
          redir /assets/reports-2021.pdf https://ngi-nix.github.io/summer-of-nix/SoN-2021-report.pdf permanent
          redir /announcements/applications-closed https://nixos.org/blog/announcements/2021/2021-06-02-applications-closed permanent
          redir /announcements/summer-of-nix-2022 https://nixos.org/blog/announcements/2022/2022-04-04-summer-of-nix-2022 permanent
          redir /live https://live.nixos.org permanent
          redir / https://github.com/ngi-nix/summer-of-nix permanent
          redir /blog https://nixos.org/blog/ permanent
          redir /announcements https://nixos.org/blog/announcements permanent
          redir /videos https://www.youtube.com/playlist?list=PLt4-_lkyRrOMWyp5G-m_d1wtTcbBaOxZk permanent
          redir /videos/son2022-public-lecture-series https://www.youtube.com/playlist?list=PLt4-_lkyRrOMWyp5G-m_d1wtTcbBaOxZk permanent
          redir /blog/callpackage-a-tool-for-the-lazy https://nix.dev/tutorials/callpackage permanent
          redir /blog/the-rise-of-special-project-infra https://nixos.org/blog/stories/2022/the-rise-of-special-project-infra permanent
          redir /blog/deploying-simple-jitsi-meet-server https://nixos.org/blog/stories/2022/deploying-simple-jitsi-meet-server permanent
          redir /blog/perldivingwithnix https://nixos.org/blog/stories/2021/perldivingwithnix permanent
        '';
      };
      virtualHosts."cryptpad.ngi.nixos.org" = {
        extraConfig = ''
          reverse_proxy 127.0.0.1:3000
        '';
      };
      virtualHosts."cryptpad-sandbox.ngi.nixos.org" = {
        extraConfig = ''
          reverse_proxy 127.0.0.1:3000
        '';
      };
    };
    openssh = {
      enable = true;
      settings.PasswordAuthentication = false;
    };
    prometheus.exporters.node = {
      enable = true;
      openFirewall = true;
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

  services.cryptpad = {
    enable = true;
    settings = {
      adminKeys = [ "[ngi-admin@cryptpad.ngi.nixos.org/Ui7gtoWnofGwBr3blP3a0SIZ2eWa+DP9C76+xCdWR28=]" ];
      httpUnsafeOrigin = "https://cryptpad.ngi.nixos.org";
      httpSafeOrigin = "https://cryptpad-sandbox.ngi.nixos.org/";
      httpAddress = "127.0.0.1";
      httpPort = 3000;
      adminEmail = "ngi@nixos.org";
      defaultStorageLimit = 1024 * 1024 * 1024;
      maxUploadSize = 100 * 1024 * 1024;
      filePath = "./datastore/";
      archivePath = "./data/archive";
      pinPath = "./data/pins";
      taskPath = "./data/tasks";
      blockPath = "./block";
      blobPath = "./blob";
      blobStagingPath = "./data/blobstage";
      logPath = "./data/logs";
      logLevel = "info";
      logFeedback = false;
      verbose = false;
      blockDailyCheck = true;
      removeDonateButton = true;
      disableAnonymousStore = true;
      disableCrowdfundingMessages = true;
    };
  };

  networking = {
    hostId = "5240310e";
    firewall.allowedTCPPorts = [
      80
      443
    ];
    firewall.allowPing = true;
    firewall.logRefusedConnections = true;
  };

  boot.loader.grub = {
    devices = [
      "/dev/nvme0n1"
      "/dev/nvme1n1"
    ];
    copyKernels = true;
  };
}
