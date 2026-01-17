/**
  # Options

  - `summary`

    Short description of the project

  - `subgrants`

    Funding that projects receive from NLnet (see [subgrant](#libsubgrant))

  - `links`

    Resources that may help with packaging (see [link](#liblink))
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

  ngiTypes = import ./. { inherit lib; };

  inherit (ngiTypes)
    link
    subgrant
    ;
in

{
  options = {
    summary = mkOption {
      type = with types; nullOr str;
      default = null;
      description = "Short description of the project";
    };
    subgrants = mkOption {
      type = with types; nullOr subgrant;
      default = null;
      description = "Funding that projects receive from NLnet";
    };
    links = mkOption {
      type = types.submodule {
        freeformType = with types; attrsOf link;

        # mandatory links
        # TODO: add all mandatory links to projects, then remove `default = null`
        options = {
          homepage = mkOption {
            type = with types; nullOr link;
            description = "Project homepage";
            default = null;
          };
          repo = mkOption {
            type = with types; nullOr link;
            description = "Main source repository";
            default = null;
          };
          docs = mkOption {
            type = with types; nullOr link;
            description = "Documentation";
            default = null;
          };
        };
      };
      default = { };
      description = "Resources and links related to the project";
    };
  };
}
