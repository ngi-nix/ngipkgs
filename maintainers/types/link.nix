/**
  Resources that may help with packaging and using a software.

  :::{.example}

  ```nix
  metadata.links = {
    source = {
      text = "Project repository";
      url = "https://github.com/ngi-nix/ngipkgs/";
    };
    docs = {
      text = "Documentation";
      url = "https://github.com/ngi-nix/ngipkgs/blob/main/CONTRIBUTING.md";
    };
  };
  ```

  :::
*/

{
  lib,
  name,
  ...
}:

let
  inherit (lib)
    types
    mkOption
    ;
in

{
  options = {
    text = mkOption {
      description = "link text";
      type = with types; str;
      default = name;
    };
    description = mkOption {
      description = "long-form description of the linked resource";
      type = with types; nullOr str;
      default = null;
    };
    # TODO: add syntax checking
    url = mkOption {
      type = with types; str;
      description = "URL of the linked resource";
    };
  };
}
