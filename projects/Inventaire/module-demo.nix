{
  lib,
  config,
  ...
}:
let
  cfg = config.services.inventaire;
in
{
  config = lib.mkIf cfg.enable {
    programs.bash.interactiveShellInit = ''
      echo "Inventaire is starting. Please wait ..."
      until systemctl show inventaire.service | grep -q ActiveState=active; do sleep 1; done
      echo "Inventaire is ready at http://localhost:${toString cfg.settings.port}"
    '';
  };
}
