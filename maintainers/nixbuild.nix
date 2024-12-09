{
  lib,
  pkgs,
  ...
}:
let
  identityFile = null
  /*
    OPTIONAL: Set this to a string containing the absolute path of your private key for convenience.
    Leaving it to `null` will not fail.
  */
  ;

  trusted = true
  /*
    Leave `true` unless you have a particular reason not to! See:
     - <https://nixos.org/manual/nix/stable/command-ref/conf-file.html?highlight=substituters#conf-substituters>
     - <https://nixos.org/manual/nix/stable/command-ref/conf-file.html?highlight=substituters#conf-trusted-substituters>
  */
  ;

  useEuropeanZone = false;
  hostName = (lib.optionalString useEuropeanZone "eu.") + "nixbuild.net";
in
{
  programs.ssh = {
    knownHosts.${hostName}.publicKey =
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIPIQCZc54poJ8vqawd8TraNryQeJnvH1eLpIDgbiqymM";
    extraConfig = ''
      Host ${hostName}
        PubkeyAcceptedKeyTypes ssh-ed25519
        ServerAliveInterval 60
        IPQoS throughput
        ${lib.optionalString (identityFile != null) "IdentityFile ${identityFile}"}
    '';
  };

  nix = {
    distributedBuilds = true;
    buildMachines = [
      {
        inherit hostName;
        system = "x86_64-linux,aarch64-linux";
        maxJobs = 100;
        supportedFeatures = [
          "benchmark"
          "big-parallel"
          "kvm"
          "nixos-test"
        ];
      }
    ];
    settings =
      let
        substituter = "ssh://${hostName}";
      in
      {
        substituters = [ substituter ];
        trusted-substituters = lib.optional trusted substituter;
        trusted-public-keys = [
          "nixbuild.net/lorenz.leutgeb@gmail.com-1:1MK1QRG65KcunlFM6zRtfnWlMLqS+03NKye1V1M9qXY="
        ];
      };
  };

  environment.systemPackages = [
    (pkgs.writeShellApplication {
      name = "nixbuild";
      runtimeInputs = with pkgs; [ rlwrap ];
      text = "rlwrap ssh ${hostName} shell";
    })
  ];
}
