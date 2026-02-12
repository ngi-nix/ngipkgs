{
  lib,
  writeShellApplication,

  ngipkgs,
  sources,
}:
(writeShellApplication {
  name = "update-all";
  meta.description = "updates all the NGIpkgs packages";
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
        "peertube-plugins.livechat"
        "_0wm-server"
        # FIX: dream2nix
        "liberaforms"
        # FIX: package scope.  #2154 supports package scope, so this probably can be removed
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
      update-packages = lib.pipe ngipkgs [
        (lib.filterAttrs (n: _: !lib.elem n skipped-packages)) # a pkg, a pkg set
        (lib.flattenAttrs ".")
        (lib.filterAttrs (n: _: !lib.elem n skipped-packages)) # a pkg, a pkg in a pkg set
        (lib.filterAttrs (_: v: lib.isDerivation v))
        (lib.filterAttrs (_: v: lib.hasAttr "updateScript" v))
        lib.attrNames
      ];
      update-commands = lib.concatMapStringsSep "\n" (package: ''
        if ! update "${sources.nixpkgs}" "${package}" "$@"; then
          echo "${package}" >> "$TMPDIR/failed_updates.txt"
        fi
      '') update-packages;
    in
    # bash
    ''
      TMPDIR=$(mktemp -d)

      echo -n> "$TMPDIR/failed_updates.txt"

      ${lib.readFile ./update.sh}

      ${update-commands}

      if [ -s "$TMPDIR/failed_updates.txt" ]; then
        echo -e "\nFailed to update the following packages:"
        cat "$TMPDIR/failed_updates.txt"
      else
        echo "All packages updated successfully!"
      fi
    '';
})
