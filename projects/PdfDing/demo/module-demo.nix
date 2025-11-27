{
  lib,
  config,
  pkgs,
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

    services.pdfding.installWrapper = true;
    services.pdfding.installTestHelpers = true;

    systemd.services.pdfding.path = [ pkgs.sqlite ];
    systemd.services.pdfding.postStart = ''
      export DJANGO_SUPERUSER_PASSWORD=admin

      ${cfg.package}/bin/pdfding-manage \
        createsuperuser \
          --no-input \
          --username admin \
          --email admin@localhost || echo "Admin user already exists. Skipping."

      # Use grid layout by default
      sqlite3 \
        /var/lib/pdfding/db/db.sqlite3 \
        "UPDATE users_profile SET layout = 'Grid' WHERE layout = 'Compact';"
    '';

    systemd.services.pdfding-background.postStart = ''
      # copy example file to consume it
      install -D \
        ${pkgs.pdfding.src}/pdfding/pdf/tests/data/dummy.pdf \
        /var/lib/pdfding/consume/1/example.pdf

      /run/current-system/sw/bin/consume-immediate
    '';
  };
}
