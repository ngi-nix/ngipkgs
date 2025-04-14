{
  lib,
  pkgs,
  sources,
}@args:

{
  metadata = {
    summary = "A project to provide fast, efficient and scalable communication by leveraging IPv6 multicast";
    subgrants = [
      "LibreCastLiveStudio"
      "Librecast-OverlayMulticast"
      "LibrecastLive"
    ];
  };

  nixos.modules.programs = {
    librecast = {
      module = ./module.nix;
      examples.basic = {
        module = ./example.nix;
        description = "";
        tests.basic = null;
      };
    };
  };
}
