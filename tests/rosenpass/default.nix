{configurations, ...}: {
  name = "rosenpass tests";

  nodes = let
    vmConfig = {
      pkgs,
      config,
      ...
    }: {
      imports = [configurations.common];
      environment.systemPackages = with pkgs; [
        rosenpass
        wireguard-tools
        tcpdump
        git
        tmux
        htop
        vim
      ];

      sops = pkgs.lib.mkForce {
        age.keyFile = ./sops/keys.txt;
      };

      networking.firewall.enable = false;

      # boot.extraModulePackages = [config.boot.kernelPackages.wireguard];
      boot.kernelModules = ["wireguard"];
      systemd.network = {
        enable = true;
        networks."rosenpass" = {
          matchConfig.Name = "rp0";
          networkConfig = {IPForward = true;};
        };

        netdevs."10-rp0" = {
          netdevConfig = {
            Kind = "wireguard";
            Name = "rp0";
          };
          wireguardConfig = {
            PrivateKeyFile = config.sops.secrets."wireguard/wgsk".path;
          };
        };
      };

      virtualisation.memorySize = 2048;
      virtualisation.cores = 2;

      # Use kmscon <https://www.freedesktop.org/wiki/Software/kmscon/>
      # to provide a slightly nicer console, and while we're at it,
      # also use a nice font.
      # With kmscon, we can for example zoom in/out using [Ctrl] + [+]
      # and [Ctrl] + [-]
      services.kmscon = {
        enable = true;
        fonts = [
          {
            name = "Fira Code";
            package = pkgs.fira-code;
          }
        ];
      };
    };
  in {
    server = {
      pkgs,
      config,
      ...
    }: {
      imports = [vmConfig];

      sops.secrets = {
        "wireguard/wgsk" = {
          sopsFile = ./sops/server.yaml;
          owner = "systemd-network";
          group = "systemd-network";
        };
        "rosenpass-pqsk" = {
          sopsFile = ./sops/server-pqsk.yaml;
          format = "binary";
          owner = config.services.rosenpass.user;
          group = config.services.rosenpass.group;
        };
      };

      networking.firewall = {
        allowedUDPPorts = [9999 10000];
      };

      systemd.network = {
        netdevs."10-rp0" = {
          wireguardConfig = {
            ListenPort = 10000;
          };
          wireguardPeers = [
            {
              wireguardPeerConfig = {
                AllowedIPs = ["::/0"];
                PublicKey = "Mb3GOlT7oS+F3JntVKiaD7SpHxLxNdtEmWz/9FMnRFU=";
              };
            }
          ];
        };

        networks."rosenpass" = {
          address = ["fe80::1/64"];
        };
      };

      environment.etc = {
        "rosenpass/pqpk" = {
          source = ./peers/server/pqpk;
          user = config.services.rosenpass.user;
          group = config.services.rosenpass.group;
        };
        "rosenpass/peers/client/pqpk" = {
          source = ./peers/client/pqpk;
          user = config.services.rosenpass.user;
          group = config.services.rosenpass.group;
        };
      };

      services.rosenpass = {
        enable = true;
        publicKeyFile = "/etc/rosenpass/pqpk";
        secretKeyFile = config.sops.secrets."rosenpass-pqsk".path;
        listen = ["0.0.0.0:9999"];
        defaultDevice = "rp0";
        peers = [
          {
            publicKeyFile = "/etc/rosenpass/peers/client/pqpk";
            wireguard.publicKey = "Mb3GOlT7oS+F3JntVKiaD7SpHxLxNdtEmWz/9FMnRFU=";
          }
        ];
      };
    };
    client = {
      pkgs,
      config,
      ...
    }: {
      imports = [vmConfig];

      sops.secrets = {
        "wireguard/wgsk" = {
          sopsFile = ./sops/client.yaml;
          owner = "systemd-network";
          group = "systemd-network";
        };
        "rosenpass-pqsk" = {
          sopsFile = ./sops/client-pqsk.yaml;
          format = "binary";
          owner = config.services.rosenpass.user;
          group = config.services.rosenpass.group;
        };
      };

      systemd.network = {
        networks."rosenpass" = {
          address = ["fe80::2/64"];
        };

        netdevs."10-rp0" = {
          wireguardPeers = [
            {
              wireguardPeerConfig = {
                AllowedIPs = ["::/0"];
                PublicKey = "mQufmDFeQQuU/fIaB2hHgluhjjm1ypK4hJr1cW3WqAw=";
                Endpoint = "server:10000";
              };
            }
          ];
        };
      };

      environment.etc = {
        "rosenpass/pqpk" = {
          source = ./peers/client/pqpk;
          user = config.services.rosenpass.user;
          group = config.services.rosenpass.group;
        };
        "rosenpass/peers/server/pqpk" = {
          source = ./peers/server/pqpk;
          user = config.services.rosenpass.user;
          group = config.services.rosenpass.group;
        };
      };

      services.rosenpass = {
        enable = true;
        publicKeyFile = "/etc/rosenpass/pqpk";
        secretKeyFile = config.sops.secrets."rosenpass-pqsk".path;
        defaultDevice = "rp0";
        peers = [
          {
            publicKeyFile = "/etc/rosenpass/peers/server/pqpk";
            endpoint = "server:9999";
            wireguard.publicKey = "mQufmDFeQQuU/fIaB2hHgluhjjm1ypK4hJr1cW3WqAw=";
          }
        ];
      };
    };
  };

  testScript = {nodes, ...}: ''
    start_all()

    with subtest("rosenpass"):
        server.wait_for_unit("rosenpass.service")
        client.wait_for_unit("rosenpass.service")
        client.succeed("ping -c 2 -i 0.5 fe80::1%rp0")
        server.wait_until_succeeds("wg show all preshared-keys | grep -v none", timeout=5)
  '';
}
