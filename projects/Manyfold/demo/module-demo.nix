{
  lib,
  config,
  ...
}:
let
  cfg = config.services.manyfold;
in
{
  config = lib.mkIf cfg.enable {
    programs.bash.interactiveShellInit = ''
      echo "Manyfold is starting. Please wait ..."
      until systemctl show manyfold.service | grep -q ActiveState=active; do sleep 1; done
      echo "Manyfold is ready at http://localhost:${toString cfg.port}"
    '';
  };
}
