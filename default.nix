{
  system ? builtins.currentSystem,
  inputs ? import ./nix/flake-compat/inputs.nix,
  self ? import ./nix/flake-compat/self.nix,
  nixpkgs ? inputs.nixpkgs,
  dream2nix ? inputs.dream2nix,
  sops-nix ? inputs.sops-nix,
}: let
  lib = import (nixpkgs + "/lib");
  lib' = import ./lib.nix {inherit lib;};
  helpers = import ./nix/helpers.nix {inherit nixpkgs dream2nix sops-nix;};

  inherit
    (builtins)
    attrValues
    ;

  inherit
    (lib')
    mapAttrByPath
    ;

  inherit
    (helpers)
    importNgiPackages
    importNgiProjects
    rawOutputs
    ;

  pkgs = import nixpkgs {
    inherit system;
  };

  ngiPackages = importNgiPackages pkgs;

  ngiProjects = importNgiProjects (pkgs // ngiPackages);

  optionsDoc = pkgs.nixosOptionsDoc {
    options =
      (import (nixpkgs + "/nixos/lib/eval-config.nix") {
        inherit system;
        modules =
          [
            {
              networking = {
                domain = "invalid";
                hostName = "options";
              };

              system.stateVersion = "23.05";
            }
          ]
          ++ attrValues rawOutputs.nixosModules;
      })
      .options;
  };
in
  ngiPackages
  // {
    overview = import ./overview {
      lib = import (nixpkgs + "/lib");
      inherit pkgs self;
      projects = ngiProjects;
      options = optionsDoc.optionsNix;
    };

    options =
      pkgs.runCommand "options.json" {
        build = optionsDoc.optionsJSON;
      } ''
        mkdir $out
        cp $build/share/doc/nixos/options.json $out/
      '';

    nixosTests = mapAttrByPath ["nixos" "tests"] {} ngiProjects;
  }
