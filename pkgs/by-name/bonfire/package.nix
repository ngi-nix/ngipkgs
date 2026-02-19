{
  _experimental-update-script-combinators,
  callPackage,
  fetchFromGitHub,
  gitUpdater,
  gitMinimal,
  lib,
  writeText,
  writeShellApplication,
}:
let
  generic = callPackage ./generic.nix { };
  flavours = [
    # FixMe(+completeness): enable when fixed upstream.
    # Issue: https://github.com/bonfire-networks/bonfire-app/issues/1737
    #"community"
    # FixMe(+completeness): generate deps.nix
    #"cooperation"
    #"coordination"
    "ember"
    "open_science"
    "social"
  ];
in

lib.recurseIntoAttrs (
  lib.makeExtensible (
    finalFlavours:
    lib.genAttrs flavours (
      flavour:
      generic.overrideAttrs (
        finalAttrs: previousAttrs: {
          pname = "bonfire";
          version = "1.0.2-alpha.32";
          src = fetchFromGitHub {
            owner = "bonfire-networks";
            repo = "bonfire-app";
            tag = "v${finalAttrs.version}";
            hash = "sha256-+C7Ts7MuDR6GwZ/G16GZw1E5VO2snTBb4tcffdC6GK4=";
          };
          passthru = lib.recursiveUpdate previousAttrs.passthru {
            env.FLAVOUR = flavour;
          };
        }
      )
    )
    // {
      update =
        (writeText "${finalFlavours.ember.pname}-${finalFlavours.ember.version}" ''
          This package only exists to provide a location for an `updateScript`
          updating `src` only once before calling each flavour's `update.script`.
        '').overrideAttrs
          {
            # Let `update-source-version` find where to update `version` and `hash`.
            pos = builtins.unsafeGetAttrPos "src" finalFlavours.ember;
            passthru = {
              inherit (finalFlavours.ember) src;
              updateScript = _experimental-update-script-combinators.sequence [
                (gitUpdater { rev-prefix = "v"; })
                {
                  command = lib.getExe (writeShellApplication {
                    name = "bonfire-update-flavours";
                    runtimeInputs = [
                      gitMinimal
                    ];
                    text = lib.concatLines [
                      # Avoid a costly update if `gitUpdater` has not modified this file.
                      ''
                        if git diff --exit-code -- pkgs/by-name/bonfire/package.nix; then
                          exit 0
                        fi
                      ''
                      # Clean everything to begin with to avoid leftovers.
                      ''
                        rm -rf pkgs/by-name/bonfire/extensions/*/
                        mkdir -p pkgs/by-name/bonfire/extensions/
                      ''
                      # Updating all flavours using the same `src` set by `gitUpdater`
                      # to avoid any flavour ending up using a `src` no longer matching
                      # the files generated in pkgs/by-name/bonfire/extensions/${flavour}/,
                      # which can happen when upstream releases a new version
                      # during the update of a flavour,
                      # which is likely since each flavour update takes roughly one hour.
                      (lib.concatMapStringsSep "\n" (
                        flavour:
                        lib.optionalString (!(finalFlavours.${flavour}.meta.broken or false)) ''
                          ${lib.getExe finalFlavours.${flavour}.passthru.update.script}
                        ''
                      ) flavours)
                    ];
                  });
                  supportedFeatures = [ "silent" ];
                }
              ];
            };
          };
    }
  )
)
