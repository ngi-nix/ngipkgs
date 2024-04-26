{
  config,
  lib,
  pkgs,
  ...
}: {
  imports = [./hardware-configuration.nix];

  networking.firewall.allowedTCPPorts =
    [80 443]
    ++ [config.services.owncast.rtmp-port];

  security.acme.defaults.email = "bryanhonof@gmail.com";

  services.owncast.enable = true;

  services.caddy = {
    enable = true;
    email = config.security.acme.defaults.email;
    virtualHosts = {
      "live.nixos.org".extraConfig = let
        owncastWebService = "http://${config.services.owncast.listen}:${
          toString config.services.owncast.port
        }";
      in ''
        encode gzip
        reverse_proxy ${owncastWebService}
      '';
      "live.bjth.xyz".extraConfig = let
        owncastWebService = "http://${config.services.owncast.listen}:${
          toString config.services.owncast.port
        }";
      in ''
        encode gzip
        reverse_proxy ${owncastWebService}
      '';
    };
  };

  boot.cleanTmpDir = true;

  zramSwap.enable = true;

  networking.hostName = "son-32gb-nbg1-2";

  services.openssh = {
    enable = true;
    passwordAuthentication = false;
  };

  security.sudo = {
    enable = true;
    wheelNeedsPassword = false;
  };

  systemd.extraConfig = ''
    DefaultStandardOutput=journal
    DefaultStandardError=journal
  '';

  users.mutableUsers = false;

  users.users = {
    ctem = {
      isNormalUser = true;
      description = "N.A.";
      extraGroups = ["wheel"];
      openssh.authorizedKeys.keys = [
        "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAACAQCiejBxtvIKB6izv7UDIDfXtsykP+oNmw/Ii3klmFiSUdB7WRso78QastE2JpmVLtRmEtzq3Yamd44xrV1wyqjUG7FiL+fFRYtr3QdY0NE1pV70hwVfCIRL/2TmrcZ9Y3vgLjAS3+uFoF8FHsS74I9OyD/6za+Z0coUp3b9ZNJngtmLHFYMiSkdH8yKetP8aVKVf5LBpMLYGk85Jjdp0Hu82IKGg41i7SLTRCGxAGeVpHpRR42puTb1sWALJQ3ATjR+f8I7+tY1v7uJGA5eXC9hxILVtp6yIXMldDUaL4VGpnKRc1//2RUO0gZ44tgIkDM/IvLeseGU7neJNzKI/xYQx/C0VraGa/9XjKLTyMbuHPHdMW9uykeUXtpnLE2dbJSaeP0KIHmY2JCS+0kBliS7X8//Mmg1CKaOtK1z8Ddp9qN/1CV/qjFY1NYcEFEyvNfFoMTfIA8V0B1ofzQ4nT5eW99o34x6fjZBYJqBQN/H7ql2Tah+wXb1tRWHzIx1KWN62S1NT3vg1n5TVc0b+UZHjuCB3QBaIPTXX2CFbmXFbWQp1yb+SHnzznNwdZwI/AOYeyDznse+QR2COKg1Wd2qYzpFGv0RSingqyKfq0d8d+AprqNEDGH6WC7W7R0yKjLxOhbUvbquhtvgREctMO9L9FFJDtSlzdSUQ6HjhFkkGw=="
      ];
    };
    bryan = {
      isNormalUser = true;
      description = "Bryan Honof";
      extraGroups = ["wheel"];
      openssh.authorizedKeys.keys = [
        "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIM5IqWTmlvq/DAFNRb8XFZRcs3iO3Pwv4uTHEzkf8L1z bryanhonof@gmail.com"
      ];
    };
  };

  users.users.root.openssh.authorizedKeys.keys = [];

  nix = {
    package = pkgs.nix;
    extraOptions = ''
      experimental-features = nix-command flakes ca-derivations recursive-nix impure-derivations
      min-free = ${toString (10000 * 1024 * 1024)}
    '';
    trustedUsers = ["root" "@wheel"];
    binaryCaches = ["https://nix-community.cachix.org"];
    binaryCachePublicKeys = [
      "nix-community.cachix.org-1:mB9FSh9qf2dCimDSUo8Zy7bkq5CX+/rkCWyvRCYg3Fs="
    ];
    gc = {
      automatic = true;
      dates = "weekly";
      options = "--delete-older-than 7d";
    };
  };
}
