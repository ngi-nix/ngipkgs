{
  flake-inputs ? import (fetchTarball {
    url = "https://github.com/fricklerhandwerk/flake-inputs/tarball/4.1.0";
    sha256 = "1j57avx2mqjnhrsgq3xl7ih8v7bdhz1kj3min6364f486ys048bm";
  }),
  flake ? flake-inputs.import-flake { src = ./.; },
  sources ? flake.inputs,
  system ? builtins.currentSystem,
  pkgs ? import sources.nixpkgs {
    config = { };
    overlays = import ./pkgs/overlays.nix { inherit lib; };
    inherit system;
  },
  lib ? import "${sources.nixpkgs}/lib",
}:
let
  devLib = import ./pkgs/lib.nix { inherit lib sources system; };

  default = devLib.customScope pkgs.newScope (self: {
    lib = lib.extend self.overlays.devLib;

    inherit
      devLib
      pkgs
      system
      sources
      flake
      default # expose final scope
      flakeAttrs
      ;
  overlays.default =
    final: prev:
    import ./pkgs/by-name {
      pkgs = prev;
      inherit lib dream2nix mkSbtDerivation;
    };

  # apply package fixes
  overlays.fixups = import ./pkgs/overlays.nix { inherit lib; };
    ngipkgs = self.import ./pkgs/by-name { };


  nixos-modules =
    with lib;
    # TODO: this is a weird shape for what we need: ngipkgs, services, modules?
    {
      # Allow using packages from `ngipkgs` to be used alongside regular `pkgs`
      ngipkgs =
        { ... }:
        {
          nixpkgs.overlays = [ overlays.default ] ++ overlays.fixups;
        };
    }
    // foldl recursiveUpdate { } (map (project: project.nixos.modules) (attrValues hydrated-projects));

  overview = import ./overview {
    inherit lib projects;
    self = flake;
    pkgs = pkgs.extend overlays.default;
    options = optionsDoc.optionsNix;
  };

  optionsDoc = pkgs.nixosOptionsDoc {
    inherit
      (lib.evalModules {
        modules = [
          {
            nixpkgs.hostPlatform = system;

            networking = {
              domain = "invalid";
              hostName = "options";
            };

            system.stateVersion = "23.05";
          }
          ./overview/demo/shell.nix
        ]
        ++ extendedNixosModules;
        specialArgs.modulesPath = "${sources.nixpkgs}/nixos/modules";
      })
      options
      ;
  };

    project-utils = self.import ./projects {
      pkgs = pkgs.extend default.overlays.default;
      sources = {
        inputs = sources;
        modules = default.nixos-modules;
        examples = lib.mapAttrs (
          _: project: lib.mapAttrs (_: example: example.module) project.nixos.examples
        ) self.hydrated-projects;
      };

  shell = pkgs.mkShellNoCC {
    packages = [
      # live overview watcher
      (pkgs.devmode.override {
        buildArgs = "-A overview --show-trace -v";
      })

      (pkgs.writeShellApplication {
        # TODO: have the program list available tests
        name = "ngipkgs-test";
        text = ''
          export pr="$1"
          export proj="$2"
          export test="$3"
          # remove the first args and feed the rest (for example flags)
          export args="''${*:4}"

          nix build --override-input nixpkgs "github:NixOS/nixpkgs?ref=pull/$pr/merge" .#checks.x86_64-linux.projects/"$proj"/nixos/tests/"$test" "$args"
        '';
      })

      # NOTE: currently, this only works with flakes, because `nix-update` can't
      # find `maintainers/scripts/update.nix` otherwise
      #
      # nix-shell --run 'update PACKAGE_NAME --use-update-script'
      (pkgs.writeShellApplication {
        name = "update";
        runtimeInputs = with pkgs; [ nix-update ];
        text = ''
          package=$1; shift # past value
          nix-update --flake --use-update-script "$package" "$@"
        '';
      })

      (pkgs.writeShellApplication {
        name = "update-all";
        runtimeInputs = with pkgs; [ nix-update ];
        text =
          let
            skipped-packages = [
              "atomic-browser" # -> atomic-server
              "atomic-cli" # -> atomic-server
              "firefox-meta-press" # -> meta-press
              "inventaire" # -> inventaire-client
              "kbin" # -> kbin-backend
              "kbin-frontend" # -> kbin-backend
              "pretalxFull" # -> pretalx
              # FIX: needs custom update script
              "marginalia-search"
              "peertube-plugin-livechat"
              # FIX: dream2nix
              "corestore"
              "liberaforms"
              # FIX: package scope
              "bigbluebutton"
              "heads"
              # FIX: don't update `sparql-queries` if there is no version change
              "inventaire-client"
              # fetcher not supported
              "libervia-backend"
              "libervia-desktop-kivy"
              "libervia-media"
              "libervia-templates"
              "sat-tmp"
              "urwid-satext"
              # broken package
              "libresoc-nmigen"
              "libresoc-verilog"
              # other issues
              "kazarma"
              "anastasis"
            ];
            update-packages = with lib; filter (x: !elem x skipped-packages) (attrNames ngipkgs);
            update-commands = lib.concatMapStringsSep "\n" (package: ''
              if ! nix-update --flake --use-update-script "${package}" "$@"; then
                echo "${package}" >> "$TMPDIR/failed_updates.txt"
              fi
            '') update-packages;
          in
          # bash
          ''
            TMPDIR=$(mktemp -d)

            echo -n> "$TMPDIR/failed_updates.txt"

            ${update-commands}

            if [ -s "$TMPDIR/failed_updates.txt" ]; then
              echo -e "\nFailed to update the following packages:"
              cat "$TMPDIR/failed_updates.txt"
            else
              echo "All packages updated successfully!"
            fi
          '';
      })

      # nix-shell --run nixdoc-to-github
      (nixdoc-to-github.lib.nixdoc-to-github.run {
        description = "NGI Project Types";
        category = "";
        file = "${toString ./projects/types.nix}";
        output = "${toString ./maintainers/docs/project.md}";
      })
    ];
  };

  metrics = import ./maintainers/metrics.nix {
    inherit
      lib
      pkgs
      ngipkgs
    inherit (self.project-utils)
      checks
      projects
      hydrated-projects
      ;

    demo-utils = self.import ./overview/demo {
      ngipkgs-modules = lib.attrValues (devLib.flattenAttrs "." self.nixos-modules);
    };

    inherit (self.demo-utils)
      # for demo code activation. used in the overview code snippets
      demo-shell
      demo-vm
      # - $(nix-build -A demos.PROJECT_NAME)
      # - nix run .#demos.PROJECT_NAME
      demos
      ;
    raw-projects = hydrated-projects;
  };

  report = import ./maintainers/report {
    inherit lib pkgs metrics;
  };

  });
in
default
# required for update scripts
// default.ngipkgs
