/**
  Funding that software authors receive from NLnet to support various software projects.
  Each subgrant comes from a fund, which is in turn bound to a grant agreement with the European commission.

  In NGIpkgs, we track: `Commons`, `Core`, `Entrust` and `Review`.
  While the first three are current fund themes, `Review` encompasses all non-current NGI funds (e.g. Assure, Discovery, PET, ...).

  See [NLnet - Thematics Funds](https://nlnet.nl/themes/) for more information.

  # Setting subgrants

  1. Navigate to the [NLnet project page](https://nlnet.nl/project/index.html)
  1. Search for a keyword related to the project (e.g. its name)
  1. Confirm that results belong to the same project
  1. Add their URL identifiers as subgrants to the project's metadata, with:

    ```
    https://nlnet.nl/project/<IDENTIFIER>/
    ```

  :::{.example}

  For the Nitrokey project, its subgrants are:

  ```nix
  metadata.subgrants = {
    Review = [ "Nitrokey" ];
    Entrust = [ "Nitrokey-3" ];
    Commons = [
      "Nitrokey-Storage"
      "Nitrokey3-FIDO-L2"
    ];
  };
  ```

  :::
*/
{
  lib,
  ...
}:

let
  inherit (lib)
    types
    mkOption
    ;
in

{
  options =
    lib.genAttrs
      [
        "Commons"
        "Core"
        "Entrust"
        "Review"
      ]
      (
        name:
        mkOption {
          description = "subgrants under the ${name} fund";
          type = with types; listOf str;
          default = [ ];
        }
      );
}
