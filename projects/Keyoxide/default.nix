{
  lib,
  pkgs,
  sources,
}@args:
{
  metadata = {
    summary = ''
      Keyoxide is a privacy-friendly tool to create and verify decentralized online identities.
    '';
    subgrants = [
      "Keyoxide"
      "Keyoxide-Mobile"
      "Keyoxide-PKO"
      "Keyoxide-signatures"
    ];
  };
  nixos.services.keyoxide = import ./keyoxide-web args;
  nixos.programs.keyoxide-cli = import ./keyoxide-cli args;
}
