{
  lib,
  callPackage,
}: let
  inherit
    (lib)
    recurseIntoAttrs
    ;

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
      (recurseIntoAttrs (callPackage ./pretalx/plugins.nix {}))
      pretalx-downstream
      pretalx-media-ccc-de
      pretalx-pages
      pretalx-venueless
      pretalx-public-voting
      ;

    libresoc = let
      libresoc-c4m-jtag = callPackage ./libresoc/c4m-jtag.nix {inherit nmigen nmigen-soc;};
      libresoc-pyelftools = callPackage ./libresoc/libresoc-pyelftools.nix {};
      mdis = callPackage ./libresoc/mdis.nix {};
      nmigen = callPackage ./libresoc/nmigen.nix {};
      nmigen-soc = callPackage ./libresoc/nmigen-soc.nix {inherit nmigen;};
      pinmux = callPackage ./libresoc/pinmux.nix {};
      power-instruction-analyzer = callPackage ./libresoc/power-instruction-analyzer.nix {};
      pytest-output-to-files = callPackage ./libresoc/pytest-output-to-files.nix {};
    in rec {
    };
  };
in
  self
