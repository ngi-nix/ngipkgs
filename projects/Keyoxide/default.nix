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
  nixos.modules.services.keyoxide = import ./keyoxide-web args;
  nixos.modules.programs.keyoxide-cli = import ./keyoxide-cli args;
}
