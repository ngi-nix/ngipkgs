{
  lib,
  config,
  ...
}:
let
  domain = "buildbot.ngi.nixos.org";
  sopsPrefix = suffix: "buildbot/${suffix}";
  secret = key: config.sops.secrets.${sopsPrefix key}.path;
in
{
  services = {
    buildbot-nix.master = {
      inherit domain;
      enable = true;
      admins = [
        "Erethon"
        "fricklerhandwerk"
        "Janik-Haag"
        "lorenzleutgeb"
        "eljamm"
        "erictapen"
        "imincik"
        "OPNA2608"
      ];
      workersFile = secret "workers";
      github = {
        oauthId = "Ov23linNGNKJg5zddrwX";
        oauthSecretFile = secret "github/oauth";
        webhookSecretFile = secret "github/webhook";
        appId = 994441;
        appSecretKeyFile = secret "buildbot.pem";
      };
      useHTTPS = true;
      cachix = {
        enable = true;
        name = "ngi";
        auth.authToken.file = config.sops.secrets."cachix".path;
      };
      showTrace = true;
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
    (builtins.listToAttrs (
      map
        (key: {
          name = sopsPrefix key;
          value = {
            inherit key;
            sopsFile = ./secrets/buildbot.json;
          };
        })
        [
          "github/oauth"
          "github/pat"
          "github/webhook"
          "worker"
        ]
    ))
    // {
      ${sopsPrefix "workers"} = {
        sopsFile = ./secrets/buildbot-workers.json;
        format = "binary";
      };
      ${sopsPrefix "buildbot.pem"} = {
        sopsFile = ./secrets/buildbot.pem;
        format = "binary";
      };
    };
}
