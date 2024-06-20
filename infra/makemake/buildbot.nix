{
  lib,
  config,
  ...
}: let
  domain = "buildbot.ngi.nixos.org";
  sopsPrefix = suffix: "buildbot/${suffix}";
  secret = key: config.sops.secrets.${sopsPrefix key}.path;
in {
  services = {
    buildbot-nix.master = {
      inherit domain;
      enable = true;
      admins = ["Erethon" "fricklerhandwerk" "Janik-Haag" "lorenzleutgeb"];
      workersFile = secret "workers";
      github = {
        oauthId = "Ov23linNGNKJg5zddrwX";
        oauthSecretFile = secret "github/oauth";
        tokenFile = secret "github/pat";
        webhookSecretFile = secret "github/webhook";
      };
      useHTTPS = true;
      cachix = {
        name = "ngi";
        authTokenFile = config.sops.secrets."cachix".path;
      };
    };

    buildbot-nix.worker = {
      enable = true;
      workerPasswordFile = secret "worker";
    };

    caddy.virtualHosts.${domain}.extraConfig = ''
      reverse_proxy localhost:8010

      header {
        Strict-Transport-Security max-age=15552000;
      }
    '';

    nginx.enable = lib.mkForce false;
  };

  sops.secrets =
    (builtins.listToAttrs
      (map (key: {
          name = sopsPrefix key;
          value = {
            inherit key;
            sopsFile = ./secrets/buildbot.json;
          };
        })
        ["github/oauth" "github/pat" "github/webhook" "worker"]))
    // {
      ${sopsPrefix "workers"} = {
        sopsFile = ./secrets/buildbot-workers.json;
        format = "binary";
      };
    };
}
