{
  _experimental-update-script-combinators,
  callPackage,
  fetchFromGitHub,
  gitUpdater,
  lib,
  stdenv,
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
stdenv.mkDerivation (finalAttrs: {
  pname = "bonfire";
  version = "1.0.2-alpha.23";
  src = fetchFromGitHub {
    owner = "bonfire-networks";
    repo = "bonfire-app";
    tag = "v${finalAttrs.version}";
    hash = "sha256-HBf3u3srhnVST0dQuJSW9/+d2grmTvkXKT3Y/6kVxa0=";
  };
  passthru =
    lib.genAttrs flavours (
      flavour:
      generic.overrideAttrs (previousAttrs: {
        inherit (finalAttrs) src version;
        passthru = lib.recursiveUpdate previousAttrs.passthru {
          env.FLAVOUR = flavour;
        };
      })
    )
    // {
      updateScript = _experimental-update-script-combinators.sequence [
        (gitUpdater { rev-prefix = "v"; })
        {
          command = [
            (lib.getExe (writeShellApplication {
              name = "bonfire-update-flavours";
              text = lib.concatMapStringsSep "\n" (flavour: ''
                ${finalAttrs.passthru.${flavour}.passthru.updateScript}
              '') flavours;
            }))
          ];
          supportedFeatures = [ "silent" ];
        }
      ];
    };
  phases = [ "installPhase" ];
  installPhase = ''
    runHook preInstall
    mkdir -p $out
    ${lib.concatMapStringsSep "\n" (flavour: ''
      ln -s ${finalAttrs.passthru.${flavour}} $out/${flavour}
    '') flavours}
    runHook postInstall
  '';
})
