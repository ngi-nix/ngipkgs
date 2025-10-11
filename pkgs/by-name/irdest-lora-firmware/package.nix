# TODO: This has not been tested yet due to not having the required hardware.
{
  path,
  lib,
  fetchFromGitea,
  stdenv,
  writeShellApplication,
  yq-go,
  nix-update,
  common-updater-scripts,

  # Configuring this properly for your jurisdiction is critical!
  # See https://codeberg.org/irdest/irdest/src/branch/main/docs/user/src/how-to/02_lora.md#frequencies.
  frequency ? null,
}:
let
  cross = import path {
    system = stdenv.hostPlatform.system;
    crossSystem = lib.systems.examples.armhf-embedded // {
      rust.rustcTarget = "thumbv7em-none-eabihf";
    };
  };
  platforms = [ "arm-none" ];
  # `buildRustPackage` removes platforms from `meta.platforms` that aren't in
  # `rustc.targetPlatforms`.
  buildRustPackage = cross.rustPlatform.buildRustPackage.override (previous: {
    rustc = previous.rustc.overrideAttrs (previousAttrs: {
      passthru = previousAttrs.passthru // {
        targetPlatforms = previousAttrs.passthru.targetPlatforms ++ platforms;
      };
    });
  });
in
buildRustPackage (finalAttrs: {
  pname = "irdest-lora-firmware";
  version = "0.1.0";

  src = fetchFromGitea {
    domain = "codeberg.org";
    owner = "irdest";
    repo = "irdest";
    rev = "b0e2113b2194e5bbef2d227f2a151fe05db0de44";
    sparseCheckout = [ "firmware/lora-modem" ];
    hash = "sha256-PNPsszwkcIRBrn8M7oLEvoFrIDIyN4Kjk1ed6+CY8Is=";
  };
  sourceRoot = "${finalAttrs.src.name}/firmware/lora-modem";

  postPatch = lib.optionalString (frequency != null) ''
    substituteInPlace src/main.rs \
      --replace-fail "const FREQUENCY: i64 = 868" "const FREQUENCY: i64 = ${toString frequency}"
  '';

  cargoHash = "sha256-0tXjW0Zw4OmuIso3MMh33c71G4mTwwU3uM4fpcKER8I=";

  RUSTFLAGS = [
    "-C"
    "linker=${cross.stdenv.cc.targetPrefix}ld"
  ];

  # Don't want `cargo-auditable` data on embedded. Also, currently conflicts with
  # upstream's use of `rustflags = [ "-C", "link-arg=-Tlink.x"]`.
  auditable = false;

  passthru.updateScript = lib.getExe (writeShellApplication {
    name = "${finalAttrs.pname}-update-script";
    text = ''
      version=$(curl https://codeberg.org/${finalAttrs.src.owner}/${finalAttrs.src.repo}/raw/branch/main/firmware/lora-modem/Cargo.toml | \
        ${lib.getExe yq-go} -e -p toml ".package.version")

      if [[ "$UPDATE_NIX_OLD_VERSION" == "$version" ]]; then
          exit 0
      fi

      ${lib.getExe nix-update} --version=branch "$UPDATE_NIX_ATTR_PATH"
      ${lib.getExe' common-updater-scripts "update-source-version"} --ignore-same-hash \
        "$UPDATE_NIX_ATTR_PATH" "$version"
    '';
  });

  meta = {
    description = "Irdest firmware for LoRa modem";
    longDescription = ''
      The frequency can be set with `.override { frequency = 123; }`, replacing "123"
      with your frequency. Configuring this properly for your jurisdiction is critical!
      See <https://codeberg.org/irdest/irdest/src/branch/main/docs/user/src/how-to/02_lora.md#frequencies>.
    '';
    homepage = "https://codeberg.org/irdest/irdest/src/branch/main/docs/user/src/how-to/02_lora.md";
    license = lib.licenses.agpl3Only;
    inherit platforms;
  };
})
