{
  lib,
  pkgs,
  sources,
}@args:

{
  metadata = {
    summary = "Privacy-friendly Proof of Work (PoW) based CAPTCHA system";
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

  nixos.services = {
    mcaptcha = {
      name = "mcaptcha";
      module = ./services/mcaptcha/module.nix;
      examples.basic = null;
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

  nixos.tests.bring-your-own-services = import ./services/mcaptcha/tests/bring-your-own-services.nix args;
  nixos.tests.create-locally = import ./services/mcaptcha/tests/create-locally.nix args;
}
