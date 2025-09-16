{ lib, ... }:
{
  programs.reoxide.enable = true;
  services.reoxided = {
    enable = true;
    settings.ghidra-install = [
      # default instance (reoxide-ghidra)
      {
        enabled = true;
      }
      # NOTE: you can supply additional ghidra instances
      # {
      #   enabled = true;
      #   root-dir = "/path/to/other/ghidra/root/dir";
      # }
    ];
  };
}
