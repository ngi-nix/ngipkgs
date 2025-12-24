{
  bonfire,
  coreutils,
  lib,
  nix,
  nurl,
  writeShellApplication,
  callPackage,
}:
let
  FLAVOUR = bonfire.passthru.env.FLAVOUR;
in
# Documentation: manuals/Contributor/How_to/update/pkgs/bonfire.md
{
  script = writeShellApplication {
    name = "bonfire-update";
    runtimeInputs = [
      bonfire.passthru.yarn-berry.yarn-berry-fetcher
      coreutils
      nix
      nurl
    ];
    text = lib.concatStringsSep "\n" [
      "set -x"

      # ToDo(maint/update): use gitUpdater instead of nurl
      # whenever all extensions have a release tag.
      #
      # Explanation: updating the extensions
      # must come before updating the dependencies in `deps.nix`,
      # which uses the extensions.
      (lib.concatMapStringsSep "\n" (flavour: ''
        mkdir -p pkgs/by-name/bonfire/extensions/${flavour}
        {
          echo "{fetchFromGitHub, ...}:"
          nurl https://github.com/bonfire-networks/${flavour}
        } >pkgs/by-name/bonfire/extensions/${flavour}/fetchFromGitHub.nix
      '') (lib.map (ext: ext.repo) bonfire.passthru.flavour-extensions))

      # Description: update pkgs/by-name/bonfire/${FLAVOUR}/deps.nix
      # using deps_nix.
      # bash
      ''
        deps=$(
            nix -L --show-trace --extra-experimental-features "nix-command" \
                build \
                --option sandbox relaxed \
                --no-link --print-out-paths \
                --repair \
                --refresh \
                -f . \
                bonfire.${FLAVOUR}.passthru.update.package
        )
        cp -f "$deps" pkgs/by-name/bonfire/extensions/${FLAVOUR}/deps.nix
      ''

      # Description: update Rust and Yarn dependencies depending on `deps.nix`.
      ''
        nix --extra-experimental-features "nix-command" -L run \
          -f . bonfire.${FLAVOUR}.updateScripts
      ''
    ];
  };

  package = callPackage ../../../profiles/pkgs/development/beam-modules/mix-update.nix {
    package = bonfire.overrideAttrs (previousAttrs: {
      pname = "${previousAttrs.pname}-${FLAVOUR}";
      preBuild = "";
      postPatch =
        previousAttrs.postPatch or ""
        + lib.concatStringsSep "\n" [
          # Explanation: re-enable downloading of locales.
          ''
            cat >>config/config.exs <<EOF
            config :bonfire_common, Bonfire.Common.Localise.Cldr,
              force_locale_download: false
            EOF
          ''
        ];
    });
    # Explanation: deps_nix needs to be injected into bonfire's mix.exs
    deps_nix_injection_pattern = "extra_deps =";
  };
}
