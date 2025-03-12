{
  lib,
  pkgs,
  sources,
}@args:

{
  name = "dream2nix";

  metadata.subgrants = [
    # FIXME: add subgrants, can't find in Notion
  ];

  nixos = {
    modules.programs.dream2nix = {
      module = null;  # not packaged in nixpkgs/ngipkgs

      examples.dream2nix = {
        module = null;
        description = "";
      };

      links = {
        documentation = {
          text = "Documentation";
          url = "https://dream2nix.dev/";
        };
      };
    };
  };
}
