{
  inputs ? import ./flake-compat/inputs.nix,
  nixpkgs ? inputs.nixpkgs,
  dream2nix ? inputs.dream2nix,
  sops-nix ? inputs.sops-nix,
}: let
  lib = import (nixpkgs + "/lib");
  lib' = import ../lib.nix {inherit lib;};

  inherit
    (lib)
    mapAttrs
    recursiveUpdate
    attrValues
    filterAttrs
    ;

  inherit
    (lib')
    flattenAttrsDot
    flattenAttrsSlash
    mapAttrByPath
    ;

  helpers = rec {
    # Imported from Nixpkgs
    nixosSystem = args:
      import (nixpkgs + "/nixos/lib/eval-config.nix") ({
          inherit lib;
          system = null;
        }
        // args);

    # NGI packages are imported from ./pkgs/by-name/default.nix.
    importNgiPackages = pkgs:
      import ../pkgs/by-name {
        inherit (pkgs) lib;
        inherit dream2nix pkgs;
      };

    # NGI projects are imported from ./projects/default.nix.
    # Each project includes packages, and optionally, modules, configurations and tests.
    importNgiProjects = pkgs:
      import ../projects {
        inherit nixpkgs dream2nix sops-nix pkgs;
      };

    # ./projects/default.nix inherits `rawExamples` and `extendedNixosModules`.
    # As configurations and modules are system-agnostic, they are defined by passing `{}` to `importNgiProjects`.
    rawNgiProjects = importNgiProjects {};

    rawExamples = flattenAttrsSlash (mapAttrs (_: v: mapAttrs (_: v: v.path) v) (
      mapAttrByPath ["nixos" "examples"] {} rawNgiProjects
    ));

    rawNixosModules = flattenAttrsDot (lib.foldl recursiveUpdate {} (attrValues (
      mapAttrByPath ["nixos" "modules"] {} rawNgiProjects
    )));

    rawOutputs = {
      nixosModules =
        {
          unbootable = ../modules/unbootable.nix;
          # The default module adds the default overlay on top of Nixpkgs.
          # This is so that `ngipkgs` can be used alongside `nixpkgs` in a configuration.
          default.nixpkgs.overlays = [rawOutputs.overlays.default];
        }
        // (filterAttrs (_: v: v != null) rawNixosModules);
      overlays.default = final: prev: importNgiPackages prev;
    };

    extendedNixosModules =
      rawOutputs.nixosModules
      // {
        sops-nix = import (sops-nix + "/modules/sops");
      };

    extendedNixosConfigurations =
      mapAttrs
      (_: config: nixosSystem {modules = [config ../dummy.nix] ++ attrValues extendedNixosModules;})
      rawExamples;
  };
in
  helpers
