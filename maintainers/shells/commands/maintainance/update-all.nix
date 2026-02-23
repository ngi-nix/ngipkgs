{
  lib,
  nix-update,
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
        "openfire" # -> openfire-unwrapped
        "pretalxFull" # -> pretalx
        # FIX: needs custom update script
        "_0wm-server"
        "funkwhale"
        "marginalia-search"
        "peertube-plugins.livechat"
        # FIX: dream2nix
        "liberaforms"
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
      ];
      update-commands = lib.concatMapAttrsStringSep "\n" (name: drv: ''
        if ! update "${sources.nixpkgs}" "${lib.getExe nix-update}" "${name}" "$@"; then
          echo "${name}" >> "$TMPDIR/failed_updates.txt"

          logfile="${drv.pname or drv.name or ""}.log"
          if [[ -f "$logfile" ]]; then
            mv "$logfile" "$TMPDIR"
          fi
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
