{configurations, ...}: let
  deviceName = "rp0";

  server = {
    ip = "fe80::1";
    wg = {
      public = "mQufmDFeQQuU/fIaB2hHgluhjjm1ypK4hJr1cW3WqAw=";
      secret = "4N5Y1dldqrpsbaEiY8O0XBUGUFf8vkvtBtm8AoOX7Eo=";
      listen = 10000;
    };
    rp = {
      secret = ./sops/server-pqsk.yaml;
      public = ./server-pqpk;
    };
  };
  client = {
    ip = "fe80::2";
    wg = {
      public = "Mb3GOlT7oS+F3JntVKiaD7SpHxLxNdtEmWz/9FMnRFU=";
      secret = "uC5dfGMv7Oxf5UDfdPkj6rZiRZT2dRWp5x8IQxrNcUE=";
    };
    rp = {
      secret = ./sops/client-pqsk.yaml;
      public = ./client-pqpk;
    };
  };
in {
  name = "rosenpass";

  nodes = let
    etcPath = config: name: "/etc/" + config.environment.etc.${name}.target;

    shared = peer: {
      config,
      modulesPath,
      pkgs,
      ...
    }: {
      imports = [configurations.common];

      boot.kernelModules = ["wireguard"];

      services.rosenpass = {
        enable = true;
        publicKeyFile = etcPath config "rosenpass/pqpk";
        secretKeyFile = etcPath config "rosenpass/pqsk";
        defaultDevice = deviceName;
      };

      networking.firewall.allowedUDPPorts = [9999];

      systemd.network = {
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
          wireguardConfig.PrivateKeyFile = etcPath config "wireguard/wgsk";
        };
      };

      environment.etc."rosenpass/pqpk" = {
        inherit (config.services.rosenpass) user group;
        source = peer.rp.public;
      };

      sops = pkgs.lib.mkForce {
        age.keyFile = ./sops/keys.txt;

        "wireguard/wgsk" = {
          sopsFile = peer.wg.secret;
          owner = "systemd-network";
          group = "systemd-network";
        };
        "rosenpass-pqsk" = {
          inherit (config.services.rosenpass) user group;
          sopsFile = peer.rp.secret;
          format = "binary";
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
        source = ./client-pqpk;
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
        source = ./server-pqpk;
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
