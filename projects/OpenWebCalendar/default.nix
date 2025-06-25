{
  pkgs,
  lib,
  sources,
  ...
}@args:
{
  metadata.subgrants = [ "OpenWebCalendar" ];
  nixos = {
    modules.services.open-web-calendar = {
      name = "open-web-calendar";
      module = lib.moduleLocFromOptionString "services.open-web-calendar";
      examples.basic = {
        module = ./example.nix;
        description = "";
        # FIX: re-enable after this is solved:
        # https://github.com/NixOS/nixpkgs/issues/418689
        # tests.basic = "${sources.inputs.nixpkgs}/nixos/tests/web-apps/open-web-calendar.nix";
        tests.basic = null;
      };
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
    demo.vm = {
      module = ./example.nix;
      description = "Deployment for demo purposes";
      # FIX: re-enable after this is solved:
      # https://github.com/NixOS/nixpkgs/issues/418689
      # tests.basic = "${sources.inputs.nixpkgs}/nixos/tests/web-apps/open-web-calendar.nix";
      tests.basic = null;
    };
  };
}
