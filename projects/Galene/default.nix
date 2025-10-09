{
  lib,
  pkgs,
  sources,
  ...
}@args:

let
  links = {
    build = {
      text = "Galene Installation";
      url = "https://galene.org/INSTALL.html";
    };
    test = {
      text = "Usage Instructions";
      url = "https://galene.org/README.html";
    };
  };
in
{
  metadata = {
    summary = "Galene is a self-hosted video conferencing server. It features advanced networking and video algorithms and automatic subtitling.";
    subgrants = [
      "Galene"
    ];
  };

  nixos.modules.services = {
    galene = {
      name = "galene";
      module = ./module.nix;
      examples."Enable Galene" = {
        module = ./example.nix;
        tests.basic.module = pkgs.nixosTests.galene.basic;
        tests.file-transfer.module = pkgs.nixosTests.galene.file-transfer;
        tests.stream.module = pkgs.nixosTests.galene.stream;
        tests.stream.problem.broken.reason = ''
          Times out after a lot of rtpsession warnings and errors.

          https://buildbot.ngi.nixos.org/#/builders/1059/builds/609
        '';
      };
      inherit links;
    };
  };
  nixos.demo.vm = {
    module = ./example.nix;
    module-demo = ./module-demo.nix;
    usage-instructions = [
      {
        instruction = ''
          To use Galène, you have to set up a group, and permissions & users within this group.
          For full details, take a look at: [${links.test.url}#group-definitions](${links.test.url}#group-definitions)
        '';
      }
      {
        instruction = ''
          After Galène has finished starting up, the on-screen text in the VM will inform you about the exact directory
          that your group configs need to be put into.
        '';
      }
      {
        instruction = ''
          An example config is available within the VM under `/etc/galene-test-config.json`. If you copy this file to
          the group directory and name it `test.json`, then a group named `test` will be available in the web interface
          for you to use.
        '';
      }
      {
        instruction = ''
          A known issue with specifically this demo is that WebRTC doesn't seem to be working: You can join the group and
          get familiar with the interface, but audio and video is unlikely to work. Installing Galène properly on a local
          system will get rid of this issue.
        '';
      }
    ];
    tests.basic.module = pkgs.nixosTests.galene.basic;
  };
}
