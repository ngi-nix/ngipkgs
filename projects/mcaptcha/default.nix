{
  lib,
  pkgs,
  sources,
}@args:

{
  metadata = {
    summary = "mCaptcha is a backend component for a CAPTCHA system designed to provide a seamless user experience without unnecessary complexity.";
    subgrants = [
      "mCaptcha"
    ];
    links = {
      website = {
        text = "Official website";
        url = "https://mcaptcha.org/";
      };
      documentation = {
        text = "Official documentation";
        url = "https://mcaptcha.org/docs/";
      };
    };
  };

  nixos.modules.services = {
    mcaptcha = {
      name = "mcaptcha";
      module = ./services/mcaptcha/module.nix;
      examples.basic = {
        module = ./services/mcaptcha/examples/basic.nix;
        description = "Basic example of mCaptcha service.";
        tests.basic = import ./services/mcaptcha/tests/basic.nix args;
      };
      # examples = {
      #   bringService = {
      #     description = "use a database and other services running on a different node";
      #     module = ./services/mcaptcha/examples/basic.nix;
      #     tests.bringService = import ./services/mcaptcha/tests/bring-your-own-services.nix args;
      #   };
      #   createLocally = {
      #     description = "use a database and other services running on the same node";
      #     module = ./services/mcaptcha/examples/basic.nix;
      #     tests.createLocally = import ./services/mcaptcha/tests/create-locally.nix args;
      #   };
      # };
      links = {
        setup = {
          text = "Development setup";
          url = "https://github.com/mCaptcha/mCaptcha/blob/master/docs/HACKING.md";
        };
        deployment = {
          text = "Deployment instructions";
          url = "https://github.com/mCaptcha/mCaptcha/blob/master/docs/DEPLOYMENT.md";
        };
        configuration = {
          text = "Configuration instructions";
          url = "https://github.com/mCaptcha/mCaptcha/blob/master/docs/CONFIGURATION.md";
        };
      };
    };
  };
}
