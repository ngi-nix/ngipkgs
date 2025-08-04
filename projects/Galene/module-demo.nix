{
  lib,
  config,
  ...
}:
let
  cfg = config.services.galene;
in
{
  config = lib.mkIf cfg.enable {
    programs.bash.interactiveShellInit = ''
      echo "Galene is starting. Please wait ..."
      until systemctl show galene.service | grep -q ActiveState=active; do sleep 1; done
      echo "Galene is ready at http://localhost:${toString cfg.httpPort}"
    '';
  };
}
