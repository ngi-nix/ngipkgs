{
  lib,
  pkgs,
  ngipkgs,
  nixdoc-to-github,
  ...
}:
pkgs.mkShellNoCC {
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
}
