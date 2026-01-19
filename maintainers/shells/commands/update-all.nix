{
  lib,
  nix-update,
  writeShellApplication,

  ngipkgs,
}:
(writeShellApplication {
  name = "update-all";
  runtimeInputs = [ nix-update ];
  meta.description = "updates all the NGIpkgs packages (nix with flakes supported required)";
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
        "_0wm-server"
        # FIX: dream2nix
        "liberaforms"
        # FIX: package scope
        "bigbluebutton"
        "heads"
        "lean-ftl"
        # FIX: don't update `sparql-queries` if there is no version change
        "inventaire-client"
        # fetcher not supported
        "libervia-backend"
        "libervia-desktop-kivy"
        "libervia-media"
        "libervia-templates"
        # broken package
        "libresoc-nmigen"
        "libresoc-verilog"
        # other issues
        "kazarma"
        "anastasis"
      ];
      update-packages = lib.filter (x: !lib.elem x skipped-packages) (lib.attrNames ngipkgs);
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
