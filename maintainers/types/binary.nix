/**
  Binary files (raw, firmware, schematics, ...).

  :::{.example}

  ```nix
  binary = {
    "nitrokey-fido2-firmware".data = pkgs.nitrokey-fido2-firmware;
    "nitrokey-pro-firmware".data = pkgs.nitrokey-pro-firmware;
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
    name = mkOption {
      type = with types; str;
      default = name;
      description = "Name of the binary asset";
    };
    data = mkOption {
      type = with types; nullOr (either path package);
      default = null;
      description = "Data of the binary asset (raw, firmware, schematics, ...)";
    };
  };
}
