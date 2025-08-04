{
  lib,
  config,
  ...
}:
let
  cfg = config.services.nodebb;
in
{
  config = lib.mkIf cfg.enable {
    programs.bash.interactiveShellInit = ''
      echo "NodeBB is starting. Please wait ..."
      until systemctl show nodebb.service | grep -q ActiveState=active; do sleep 1; done
      echo "NodeBB is ready at http://localhost:${toString cfg.settings.port}"
    '';
  };
}
