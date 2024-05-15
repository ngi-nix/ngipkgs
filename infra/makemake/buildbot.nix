{ lib, ... }: {
  services = {
    caddy.virtualHosts."buildbot.ngi.nixos.org".extraConfig = ''
      reverse_proxy localhost:8010 {
        header_up X-Forwarded-Proto https
        header_up X-Forwarded-Port 443
      }

      header {
        Strict-Transport-Security max-age=15552000;
      }
    '';
  };

  services.buildbot-nix.master = {
    enable = true;
    domain = "buildbot.ngi.nixos.org";
    admins = [ "Erethon" "fricklerhandwerk" "Janik-Haag" "lorenzleutgeb" ];
    workersFile = /etc/buildbot/workers.json;
    github = {
      user = "ngi-nix";
      tokenFile = /etc/buildbot/gh-token;
      oauthId = "thisneedstobeastring";
      oauthSecretFile = /etc/buildbot/gh-oauthsecret;
      webhookSecretFile = /etc/buildbot/gh-webhook;
    };
  };

  services.buildbot-nix.worker = {
    enable = true;
    workerPasswordFile = /etc/buildbot/worker1-secret;
  };

  # buildbot-nix wants to enable nginx, but we use caddy instead
  services.nginx.enable = lib.mkForce false;
}
