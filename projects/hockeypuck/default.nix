{
  lib,
  pkgs,
  ...
}@args:

{
  metadata = {
    summary = "OpenPGP keyserver";
    subgrants.Core = [
      "Hockeypuck"
    ];
    links = {
      repo = {
        text = "Source repository";
        url = "https://github.com/hockeypuck/hockeypuck";
      };
      homepage = {
        text = "Homepage";
        url = "https://hockeypuck.io";
      };
      docs = {
        text = "Title";
        url = "https://hockeypuck.io";
      };
    };
  };

  nixos.modules.services = {
    hockeypuck = {
      name = "hockeypuck";
      module = lib.moduleLocFromOptionString "services.hockeypuck";
      examples."Enable hockeypuck" = {
        module = ./services/hockeypuck/examples/basic.nix;
        tests.basic.module = pkgs.nixosTests.hockeypuck;
      };
    };
  };

  nixos.demo.vm = {
    module = ./demo/module.nix;
    module-demo = ./demo/module-demo.nix;
    description = "Demo for hockeypuck";
    tests.basic.module = pkgs.nixosTests.hockeypuck;
    usage-instructions = [
      {
        instruction = ''
          Generate GPG keyring from basic key:

          ```
          $ gpg --batch --generate-key /etc/gpg-key-foo
          $ KEY_ID=$(gpg --list-keys | grep dsa1024 --after-context=1 | grep -v dsa1024)
          ```
        '';
      }
      {
        instruction = ''
          Send the key to the local hockeypuck keyserver:

          ```
          $ gpg --keyserver hkp://127.0.0.1:11371 --send-keys "$KEY_ID"
          ```
        '';
      }
      {
        instruction = ''
          Receive the key from the local keyserver to a separate directory:

          ```
          $ GNUPGHOME=$(mktemp -d) gpg --keyserver hkp://127.0.0.1:11371 --recv-keys "$KEY_ID"
          ```
        '';
      }
      {
        instruction = ''
          Visit [http://127.0.0.1:11371](http://127.0.0.1:11371) in your browser
        '';
      }
    ];
  };
}
