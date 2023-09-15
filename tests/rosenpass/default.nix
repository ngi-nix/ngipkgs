{configurations, ...}: let
  deviceName = "rp0";

  server = {
    ip = "fe80::1";
    wg = {
      public = "mQufmDFeQQuU/fIaB2hHgluhjjm1ypK4hJr1cW3WqAw=";
      secret = {
        sopsFile = ./server/sops.yaml;
        key = "wireguard/wgsk";
      };
      listen = 10000;
    };
    rp = {
      secret = {
        sopsFile = ./server/pqsk.yaml;
        format = "binary";
      };
      public = ./server/pqpk.bin;
    };
  };
  client = {
    ip = "fe80::2";
    wg = {
      public = "Mb3GOlT7oS+F3JntVKiaD7SpHxLxNdtEmWz/9FMnRFU=";
      secret = {
        sopsFile = ./client/sops.yaml;
        key = "wireguard/wgsk";
      };
    };
    rp = {
      secret = {
        sopsFile = ./client/pqsk.yaml;
        format = "binary";
      };
      public = ./client/pqpk.bin;
    };
  };
in {
  name = "rosenpass";

  nodes = let
    sopsPath = config: name: config.sops.secrets.${name}.path;
    etcPath = config: name: "/etc/" + config.environment.etc.${name}.target;

    shared = peer: {
      config,
      modulesPath,
      ...
    }: {
      imports = [configurations.shared];

      boot.kernelModules = ["wireguard"];

      services.rosenpass = {
        enable = true;
        publicKeyFile = etcPath config "rosenpass/pqpk";
        secretKeyFile = sopsPath config "rosenpass/pqsk";
        defaultDevice = deviceName;
      };

      networking.firewall.allowedUDPPorts = [9999];

      systemd = {
        network = {
          enable = true;
          networks."rosenpass" = {
            matchConfig.Name = deviceName;
            networkConfig.IPForward = true;
            address = ["${peer.ip}/64"];
          };

          netdevs."10-rp0" = {
            netdevConfig = {
              Kind = "wireguard";
              Name = deviceName;
            };
            wireguardConfig.PrivateKeyFile = sopsPath config "wireguard/wgsk";
          };
        };
      };

      environment.etc."rosenpass/pqpk" = {
        inherit (config.services.rosenpass) user group;
        source = peer.rp.public;
      };

      sops = {
        age.keyFile = ./keys.txt;
        secrets = {
          "wireguard/wgsk" =
            peer.wg.secret
            // {
              owner = "systemd-network";
              group = "systemd-network";
            };
          "rosenpass/pqsk" =
            peer.rp.secret
            // {
              inherit (config.services.rosenpass) group;
              owner = config.services.rosenpass.user;
            };
        };
      };
    };
  in {
    server = {config, ...}: {
      imports = [(shared server)];

      networking.firewall.allowedUDPPorts = [server.wg.listen];

      systemd.network.netdevs."10-${deviceName}" = {
        wireguardConfig.ListenPort = server.wg.listen;
        wireguardPeers = [
          {
            wireguardPeerConfig = {
              AllowedIPs = ["::/0"];
              PublicKey = client.wg.public;
            };
          }
        ];
      };

      services.rosenpass = {
        listen = ["0.0.0.0:9999"];
        peers = [
          {
            publicKeyFile = etcPath config "rosenpass/peers/client/pqpk";
            wireguard.publicKey = client.wg.public;
          }
        ];
      };

      environment.etc."rosenpass/peers/client/pqpk" = {
        inherit (config.services.rosenpass) user group;
        source = ./client/pqpk.bin;
      };
    };
    client = {config, ...}: {
      imports = [(shared client)];

      systemd.network.netdevs."10-${deviceName}".wireguardPeers = [
        {
          wireguardPeerConfig = {
            AllowedIPs = ["::/0"];
            PublicKey = server.wg.public;
            Endpoint = "server:${builtins.toString server.wg.listen}";
          };
        }
      ];

      services.rosenpass = {
        peers = [
          {
            publicKeyFile = etcPath config "rosenpass/peers/server/pqpk";
            endpoint = "server:9999";
            wireguard.publicKey = server.wg.public;
          }
        ];
      };

      environment.etc."rosenpass/peers/server/pqpk" = {
        inherit (config.services.rosenpass) user group;
        source = ./server/pqpk.bin;
      };
    };
  };

  testScript = {nodes, ...}: ''
    start_all()

    with subtest("rosenpass"):
        server.wait_for_unit("rosenpass.service")
        client.wait_for_unit("rosenpass.service")

        client.succeed("ping -c 2 -i 0.5 ${server.ip}%${deviceName}")

        # Rosenpass works by setting the WireGuard preshared key at regular intervals.
        # Thus, if it is not active, then no key will be set, and the output of `wg show` will contain "none".
        # Otherwise, if it is active, then the key will be set and "none" will not be found in the output of `wg show`.
        server.wait_until_succeeds("wg show all preshared-keys | grep --invert-match none", timeout=5)
  '';
}
