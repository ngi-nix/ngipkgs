{
  lib,
  buildNpmPackage,
  fetchFromGitea,
  unstableGitUpdater,
  writeShellApplication,
  _experimental-update-script-combinators,
  nix,
  sd,
}:

buildNpmPackage rec {
  pname = "inventaire-i18n";
  version = "0-unstable-2025-06-12";

  src = fetchFromGitea {
    domain = "codeberg.org";
    owner = "inventaire";
    repo = "inventaire-i18n";
    rev = "834830455bbdf7684a55141f80e9b7a2da33d4eb";
    hash = "sha256-0FhJuHZI4NyeWg3mhb0KCqe/SOR2nNo2uOfJ2CJYXPo=";
  };

  npmDepsHash = "sha256-hJ9L9X53n44Iz0lKX2NspMLtQbQA0nRgJvYZc5+xNuA=";

  postPatch = ''
    patchShebangs scripts
  '';

  passthru = {
    updateScriptSrc = unstableGitUpdater { };
    updateScriptNpmDeps = writeShellApplication {
      name = "update-inventaire-i18n-npmDepsHash";
      runtimeInputs = [
        nix
        sd
      ];
      text = ''
        export UPDATE_NIX_ATTR_PATH="''${UPDATE_NIX_ATTR_PATH:-inventaire-i18n}"

        oldhash="$(nix-instantiate . --eval --strict -A ngipkgs."$UPDATE_NIX_ATTR_PATH".npmDepsHash | cut -d'"' -f2)"
        newhash="$(nix-build -A ngipkgs."$UPDATE_NIX_ATTR_PATH".npmDeps --no-out-link 2>&1 | tail -n3 | grep 'got:' | cut -d: -f2- | xargs echo || true)"

        if [ "$newhash" == "" ]; then
          echo "No new npmDepsHash."
          exit 0
        fi

        fname="$(nix-instantiate --eval -E "with import ./. {}; (builtins.unsafeGetAttrPos \"version\" ngipkgs.$UPDATE_NIX_ATTR_PATH).file" | cut -d'"' -f2)"
        ${sd.meta.mainProgram} --string-mode "$oldhash" "$newhash" "$fname"
      '';
    };
    updateScript = _experimental-update-script-combinators.sequence [
      passthru.updateScriptSrc.command
      (lib.getExe passthru.updateScriptNpmDeps)
    ];
  };

  meta = {
    description = "Repository hosting inventaire i18n strings and scripts";
    homepage = "https://codeberg.org/inventaire/inventaire-i18n";
    license = lib.licenses.agpl3Only;
    platforms = lib.platforms.all;
    maintainers = with lib.maintainers; [ ];
  };
}
