{
  lib,
  config,
  ...
}:
let
  cfg = config.services.pdfding;
in
{
  config = lib.mkIf cfg.enable {
    programs.bash.interactiveShellInit = ''
      echo "PdfDing is starting. Please wait ..."
      until systemctl show pdfding.service | grep -q ActiveState=active; do sleep 1; done
      echo "PdfDing is ready at http://localhost:${toString cfg.port}"
    '';
  };
}
