{
  pkgs,
  lib,
  sources,
  ...
}@args:
{
  metadata.subgrants = [ "OpenWebCalendar" ];
  nixos.services.open-web-calendar = {
    name = "open-web-calendar";
    module = "${sources.inputs.nixpkgs}/nixos/modules/services/web-apps/open-web-calendar.nix";
    examples.basic = null;
    links = {
      development = {
        text = "Development";
        url = "https://open-web-calendar.quelltext.eu/dev/";
      };
      maintain = {
        text = "Maintain the project";
        url = "https://open-web-calendar.quelltext.eu/dev/maintain/";
      };
      configure = {
        text = "Configure the service";
        url = "https://open-web-calendar.quelltext.eu/host/configure/";
      };
      executable-pypi = {
        text = "Install and run the exexutable from PyPI";
        url = "https://open-web-calendar.quelltext.eu/host/pypi/";
      };
      executable-docker = {
        text = "Install and run the exexutable with Docker";
        url = "https://open-web-calendar.quelltext.eu/host/docker/";
      };
      pypi = {
        text = "PyPI project page";
        url = "https://pypi.org/project/open-web-calendar/";
      };
    };
  };
  nixos.tests.open-web-calendar = "${sources.inputs.nixpkgs}/nixos/tests/web-apps/open-web-calendar.nix";
}
