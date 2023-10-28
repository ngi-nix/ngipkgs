{
  lib,
  callPackage,
}: let
  self = rec {
    # LiberaForms is intentionally disabled.
    # Refer to <https://github.com/ngi-nix/ngipkgs/issues/40>.
    #liberaforms = callPackage ./pkgs/liberaforms {};
    #liberaforms-env = callPackage ./pkgs/liberaforms/env.nix {};

    pretalx = callPackage ./pretalx {};
    pretalx-frontend = callPackage ./pretalx/frontend.nix {};
    pretalx-full = callPackage ./pretalx {
      withPlugins = [
        pretalx-downstream
        pretalx-media-ccc-de
        pretalx-pages
        pretalx-venueless
        pretalx-public-voting
      ];
    };

    inherit
      (lib.recurseIntoAttrs (callPackage ./pretalx/plugins.nix {}))
      pretalx-downstream
      pretalx-media-ccc-de
      pretalx-pages
      pretalx-venueless
      pretalx-public-voting
      ;

    libresoc = rec {
      libresoc-nmutil = callPackage ./libresoc/libresoc-nmutil.nix {};
      openpower-isa = callPackage ./libresoc/openpower-isa.nix {inherit power-instruction-analyzer libresoc-nmutil;};
      power-instruction-analyzer = callPackage ./libresoc/power-instruction-analyzer.nix {};
    };
  };
in
  self
