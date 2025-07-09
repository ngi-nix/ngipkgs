{
  lib,
  pkgs,
  ...
}:
let
  galeneTestGroupsDir = "/var/lib/galene/groups";
  galeneTestGroupFile = "galene-test-config.json";
  galenePort = 8443;
  galeneTestGroupAdminName = "admin";
  galeneTestGroupAdminPassword = "1234";
in
{
  services.galene = {
    enable = true;
    insecure = true;
    openFirewall = true;
    httpPort = galenePort;
    groupsDir = galeneTestGroupsDir;
  };

  # https://galene.org/INSTALL.html
  environment.etc.${galeneTestGroupFile}.source =
    (pkgs.formats.json { }).generate galeneTestGroupFile
      {
        op = [
          {
            username = galeneTestGroupAdminName;
            password = galeneTestGroupAdminPassword;
          }
        ];
        other = [ { } ];
      };

  environment.systemPackages = with pkgs; [
    ffmpeg
    galene-stream
  ];
}
