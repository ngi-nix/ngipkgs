{
  lib,
  callPackage,
  inputs,
}: let
  linuxSystem = "x86_64-linux";
  pkgsArm = import inputs.nixpkgs {
    system = linuxSystem;
    crossSystem.config = "arm-none-eabi";
  };
  pkgsAvr = import inputs.nixpkgs {
    system = linuxSystem;
    crossSystem.config = "avr";
  };
  stdenvArm = pkgsArm.stdenv;
  stdenvAvr = pkgsAvr.stdenv;
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
    nitrokey-3 = callPackage ./nitrokey-firmware/nitrokey-3 {};
    nitrokey-pro = callPackage ./nitrokey-firmware/nitrokey-pro.nix {inherit stdenvArm;};
    nitrokey-start = callPackage ./nitrokey-firmware/nitrokey-start.nix {gcc11StdenvArm = pkgsArm.gcc11Stdenv;};
    nitrokey-trng-rs232 = callPackage ./nitrokey-firmware/nitrokey-trng-rs232.nix {inherit stdenvAvr;};
  };
in
  self
