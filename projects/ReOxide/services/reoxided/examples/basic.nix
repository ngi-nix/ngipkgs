{ lib, config, ... }:
{
  programs.reoxide.enable = true;
  services.reoxided = {
    enable = true;
    settings.ghidra-install = [
      # default instance (reoxide-ghidra)
      {
        enabled = true;
        root-dir = "${config.services.reoxided.package}/opt/ghidra";
      }
      # NOTE: you can supply additional ghidra instances
      # {
      #   enabled = true;
      #   root-dir = "/path/to/other/ghidra/root/dir";
      # }
    ];
  };
}
