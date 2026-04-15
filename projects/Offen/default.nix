{
  lib,
  pkgs,
  sources,
  ...
}@args:

{
  metadata = {
    summary = "Privacy-respecting site analytics";
    subgrants.Review = [
      "OffenOne"
      "offen"
    ];
    links = {
      repo = {
        text = "Source repository";
        url = "https://github.com/offen/offen";
      };
      homepage = {
        text = "Homepage";
        url = "https://www.offen.dev";
      };
      docs = {
        text = "Documentation";
        url = "https://docs.offen.dev";
      };
    };
  };

  nixos.modules.services = {
    offen = {
      module = null;
      examples."Enable Offen server" = {
        module = null;
        tests.basic.module = null;
      };
      links = {
        guide = {
          text = "Operator Guide";
          url = "https://docs.offen.dev/running-offen/";
        };
        configure = {
          text = "Configuring the application";
          url = "https://docs.offen.dev/running-offen/configuring-the-application/";
        };
      };
    };
  };

  # TODO: the service has a demo mode
  # https://docs.offen.dev/running-offen/test-drive/
  nixos.demo = null;
}
