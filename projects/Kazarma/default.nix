{
  lib,
  pkgs,
  sources,
  ...
}@args:

{
  metadata = {
    summary = "Matrix bridge for the ActivityPub network";
    subgrants = [
      "Kazarma"
      "Kazarma-Release"
    ];
    links = {
      website = {
        text = "Website";
        url = "https://kazar.ma/";
      };
      docs = {
        text = "Documentation";
        url = "https://docs.kazar.ma/";
      };
      src = {
        text = "Source repository";
        url = "https://gitlab.com/technostructures/kazarma/kazarma";
      };
    };
  };

  nixos.modules.services = {
    kazarma = {
      name = "service name";
      module = ./services/kazarma/module.nix;
      examples."Enable kazarma" = {
        module = ./services/kazarma/examples/basic.nix;
        description = null;
        tests.basic.module = import ./services/kazarma/tests/basic.nix args;
        tests.basic.problem.broken.reason = ''
          elixir 1.17 requires erlang >= 25 and <= 27
          even when that's true, cldr compilation still fails

          See: https://github.com/ngi-nix/ngipkgs/issues/1096
        '';
      };
    };
  };
}
