{
  lib,
  config,
  ...
}:
let
  cfg = config.services.hockeypuck;
in
{
  config = lib.mkIf cfg.enable {
    programs.bash.interactiveShellInit = ''
      echo "Hockeypuck is starting. Please wait ..."
      until systemctl show hockeypuck.service | grep -q ActiveState=active; do sleep 1; done
      echo "Hockeypuck is ready at http://localhost:${toString cfg.port}"
    '';
  };
}
