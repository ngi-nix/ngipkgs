{ pkgs, service, ... }:
{ lib, ... }:

let
  settingsFormat = pkgs.formats.ini { };
in

{
  freeformType = settingsFormat.type;
  options = {
    Conference = {
      file_transfer_dir = lib.mkOption {
        type = lib.types.path;
        default = "/var/lib/${service}/file_transfer";
        description = "Directory for storing files transferred to rooms.";
      };
      screensharing_images_dir = lib.mkOption {
        type = lib.types.path;
        default = "/var/lib/${service}/screensharing_images";
        description = "Directory where images used by the Screen Sharing functionality will be stored.";
      };
    };
  };
}
