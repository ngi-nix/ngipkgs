{
  lib,
  pkgs,
  sources,
  ...
}@args:
{
  metadata = {
    summary = "Real-time collaboration server based on the XMPP protocol";
    subgrants.Core = [
      "Openfire-IPv6"
      "Openfire-Connectivity"
    ];
  };

  nixos.modules.services = {
    openfire-server = {
      module = ./services/openfire-server/module/default.nix;
      examples."Enable Openfire server" = {
        module = ./services/openfire-server/examples/basic/default.nix;
        tests.basic.module = ./services/openfire-server/examples/basic/test.nix;
      };
    };
  };

  nixos.demo.vm = {
    module = ./demo/module.nix;
    module-demo = ./demo/module-demo.nix;
    usage-instructions = [
      {
        instruction = ''
          Visit [http://127.0.0.1:9090](http://127.0.0.1:9090) in your browser
        '';
      }
      {
        instruction = ''
          Log in with the admin account:

            - username: admin
            - password: admin
        '';
      }
    ];
    tests.demo.module = ./services/openfire-server/examples/basic/test.nix;
  };
}
