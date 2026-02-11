{
  _experimental-update-script-combinators,
  callPackage,
  fetchFromGitHub,
  gitUpdater,
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
                  command = (
                    writeShellApplication {
                      name = "bonfire-update-flavours";
                      text = ''
                        rm -rf pkgs/by-name/bonfire/extensions/*/
                        mkdir -p pkgs/by-name/bonfire/extensions/
                      ''
                      + lib.concatMapStringsSep "\n" (flavour: ''
                        ${finalFlavours.${flavour}.passthru.update.script}
                      '') flavours;
                    }
                  );
                  supportedFeatures = [ "silent" ];
                }
              ];
            };
          };
    }
  )
)
