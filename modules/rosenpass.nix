{
  config,
  lib,
  options,
  pkgs,
  ...
}:
with builtins;
with lib; let
  cfg = config.services.rosenpass;
  opt = options.services.rosenpass;
in {
  options.services.rosenpass = with types; {
    enable = mkEnableOption "Whether to enable the Rosenpass service to provide post-quantum secure key exchange for WireGuard.";

    package = mkPackageOption pkgs "rosenpass" {};

    user = mkOption {
      type = str;
      default = "rosenpass";
      description = "User to run Rosenpass as.";
    };

    group = mkOption {
      type = str;
      default = "rosenpass";
      description = "Primary group of the user running Rosenpass.";
    };

    publicKeyFile = mkOption {
      type = path;
      description = "Path to a file containing the public key of the local Rosenpass peer. Generate this by running `rosenpass gen-keys`.";
    };

    secretKeyFile = mkOption {
      type = path;
      description = "Path to a file containing the secret key of the local Rosenpass peer. Generate this by running `rosenpass gen-keys`.";
    };

    defaultDevice = mkOption {
      type = nullOr str;
      description = "Name of the network interface to use for all peers by default.";
      example = "wg0";
    };

    listen = mkOption {
      type = listOf str;
      description = "List of local endpoints to listen for connections.";
      default = [];
      example = literalExpression "[ \"0.0.0.0:10000\" ]";
    };

    verbosity = mkOption {
      type = enum ["Verbose" "Quiet"];
      default = "Quiet";
      description = "Verbosity of output produced by the service.";
    };

    peers = let
      peer = submodule {
        options = {
          publicKeyFile = mkOption {
            type = path;
            description = "Path to a file containing the public key of the remote Rosenpass peer.";
          };

          endpoint = mkOption {
            type = nullOr str;
            default = null;
            description = "Endpoint of the remote Rosenpass peer.";
          };

          device = mkOption {
            type = str;
            default = cfg.defaultDevice;
            defaultText = literalExpression "config.${opt.defaultDevice}";
            description = "Name of the local WireGuard interface to use for this peer.";
          };

          wireguard = mkOption {
            type = submodule {
              options = {
                publicKey = mkOption {
                  type = str;
                  description = "WireGuard public key corresponding to the remote Rosenpass peer.";
                };
              };
            };
            description = "WireGuard configuration for this peer.";
          };
        };
      };
    in
      mkOption {
        type = listOf peer;
        description = "List of peers to exchange keys with.";
        default = [];
      };

    extraConfig = mkOption {
      type = attrs;
      description = ''
        Extra configuration to be merged with the generated Rosenpass configuration file.
      '';
      default = {};
    };
  };

  config = mkIf cfg.enable {
    warnings = let
      netdevsList = attrValues config.systemd.network.netdevs;
      publicKeyInNetdevs = peer: any (netdev: any (publicKeyInWireguardPeers peer) netdev.wireguardPeers) netdevsList;
      publicKeyInWireguardPeers = peer: x: x.wireguardPeerConfig ? PublicKey && x.wireguardPeerConfig.PublicKey == peer.wireguard.publicKey;

      # NOTE: In the message below, we tried to refer to
      #   options.systemd.network.netdevs."<name>".wireguardPeers.*.PublicKey
      # directly, but don't know how to traverse "<name>" and * in this path.
      warningMsg = peer: "It appears that you have configured a Rosenpass peer with the Wireguard public key '${peer.wireguard.publicKey}' but there is no corresponding Wireguard peer configuration in any of `${options.systemd.network.netdevs}.\"<name>\".wireguardPeers.*.PublicKey`. While this may work as expected, such a scenario is unusual. Please double-check your configuration.";
    in
      concatMap (peer: optional (!publicKeyInNetdevs peer) (warningMsg peer)) cfg.peers;

    environment.systemPackages = [cfg.package pkgs.wireguard-tools];

    users.users."${cfg.user}" = {
      isSystemUser = true;
      createHome = false;
      group = cfg.group;
    };

    users.groups."${cfg.group}" = {};

    # NOTE: It would be possible to use systemd credentials for pqsk.
    # <https://systemd.io/CREDENTIALS/>
    systemd.services.rosenpass = let
      generatePeerConfig = {
        publicKeyFile,
        endpoint,
        device,
        wireguard,
      }:
        {
          inherit device;
          public_key = publicKeyFile;
          peer = wireguard.publicKey;
          extra_params = [];
        }
        // (optionalAttrs (endpoint != null) {inherit endpoint;});

      generateConfig = {
        publicKeyFile,
        secretKeyFile,
        listen,
        verbosity,
        peers,
        ...
      }: {
        inherit listen verbosity;
        public_key = publicKeyFile;
        secret_key = secretKeyFile;
        peers = map generatePeerConfig peers;
      };
      toml = pkgs.formats.toml {};
      configFile = toml.generate "config.toml" (recursiveUpdate (generateConfig cfg) cfg.extraConfig);
    in {
      wantedBy = ["multi-user.target"];
      after = ["network-online.target"];
      path = [pkgs.wireguard-tools];

      script = "${cfg.package}/bin/rosenpass exchange-config ${configFile}";

      serviceConfig = {
        User = cfg.user;
        Group = cfg.group;
        AmbientCapabilities = ["CAP_NET_ADMIN"];
      };
    };
  };
}
