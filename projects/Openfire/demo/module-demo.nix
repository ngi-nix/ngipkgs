{
  lib,
  config,
  ...
}:
let
  cfg = config.services.openfire-server;
  port = toString cfg.servicePort;
in
{
  config = lib.mkIf cfg.enable {
    programs.bash.interactiveShellInit =
      # bash
      ''
        echo "Openfire is starting. Please wait ..."

        until systemctl status openfire-server.service \
          | grep -q "Finished processing all plugins"
        do
          sleep 1
        done

        echo "Openfire is ready at http://127.0.0.1:${port}"
      '';
  };
}
