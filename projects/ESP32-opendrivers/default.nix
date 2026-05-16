{
  lib,
  pkgs,
  sources,
  ...
}@args:

{
  metadata = {
    summary = "Open-source bare-metal Wi-Fi networking stack project for ESP32 devices aiming for a blob-free and auditable Wi-Fi SDK/firmware.";
    subgrants = {
      Core = [
        "ESP32-opendrivers"
      ];
      Commons = [
        "ESP32-async-MAC"
      ];
    };
    links = {
      homepage = {
        text = "Website";
        url = "https://esp32-open-mac.be/";
      };
      repo = {
        text = "Source repository";
        url = "https://github.com/esp32-open-mac/esp32-open-mac";
      };
      docs = {
        text = "Documentation";
        url = "https://esp32-open-mac.be/";
      };
      blog = {
        text = "Blog post: Open source ESP32 WiFi MAC";
        url = "https://zeus.ugent.be/blog/23-24/open-source-esp32-wifi-mac/";
      };
      qemu = {
        text = "ESP32 QEMU fork";
        url = "https://github.com/esp32-open-mac/qemu";
      };
      matrix = {
        text = "Matrix Chat";
        url = "https://matrix.to/#/#esp32-open-mac:matrix.org";
      };
    };
  };

  nixos = {
    # Firmware/open-driver project - no NixOS services or programs yet.
  };
}
