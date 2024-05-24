{
  sops = {
    defaultSopsFile = ../secrets.json;
    secrets = {
      cachix = {};
    };
  };
}
