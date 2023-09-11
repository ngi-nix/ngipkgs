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
      secret = ./server-pqsk;
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
      secret = ./client-pqsk;
      public = ./client-pqpk;
    };
  };
in {
  name = "rosenpass";

  nodes = let
    etcPath = config: name: "/etc/" + config.environment.etc.${name}.target;
    etcPathBin = config: name: (etcPath config name) + ".bin";

    shared = peer: {
      config,
      modulesPath,
      ...
    }: {
      imports = [configurations.common];

      boot.kernelModules = ["wireguard"];

      services.rosenpass = {
        enable = true;
        publicKeyFile = etcPathBin config "rosenpass/pqpk";
        secretKeyFile = etcPathBin config "rosenpass/pqsk";
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
            wireguardConfig.PrivateKeyFile = etcPath config "wireguard/wgsk";
          };
        };

        # Rosenpass requires keys in binary format.
        # However, we want to avoid storing binary files in the nixpkgs repository.
        # We are providing keys in base64 encoded format
        # in `/etc/rosenpass/**/*pq{p,s}k` via `environment.etc`.
        # This service decodes those files back into the binary format that
        # Rosenpass expects.
        # See also `etcPath x y` and `etcPathBin x y`.
        services."rosenpass-decode" = {
          serviceConfig.Type = "oneshot";

          before = ["rosenpass.service"];
          requiredBy = ["rosenpass.service"];

          script = ''
            set -x
            for src in $(find /etc/rosenpass -name '*pq[sp]k'); do
              dst="''${src}.bin"
              base64 --decode "$src" > "$dst"
              chown --reference "$src" "$dst"
              chmod --reference "$src" "$dst"
            done
          '';
        };
      };

      environment.etc = {
        "wireguard/wgsk" = {
          text = peer.wg.secret;
          user = "systemd-network";
          group = "systemd-network";
        };
        "rosenpass/pqpk" = {
          inherit (config.services.rosenpass) user group;
          source = peer.rp.public;
        };
        "rosenpass/pqsk" = {
          inherit (config.services.rosenpass) user group;
          source = peer.rp.secret;
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
            publicKeyFile = etcPathBin config "rosenpass/peers/client/pqpk";
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
            publicKeyFile = etcPathBin config "rosenpass/peers/server/pqpk";
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
