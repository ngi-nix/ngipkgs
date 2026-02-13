{
  lib,
  config,
  ...
}:
let
  cfg = config.services.icosa-gallery;
in
{
  config = lib.mkIf cfg.enable {
    programs.bash.interactiveShellInit = ''
      echo "Icosa Gallery is starting. Please wait ..."
      until systemctl show icosa-gallery.service | grep -q ActiveState=active; do sleep 1; done
      echo "Icosa Gallery is ready at http://localhost:${toString cfg.port}"
    '';
  };
}
