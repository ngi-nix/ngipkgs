{
  lib,
  pkgs,
  sources,
}@args:
{
  metadata = {
    summary = ''
      A minimal Linux that runs as a coreboot or LinuxBoot ROM payload to provide a secure, flexible boot environment for laptops, workstations and servers.
    '';
    subgrants = [
      "AuthenticatedHeads"
      "AccessibleSecurity"
    ];
  };

  nixos.programs = {
    heads = {
      name = "heads";
      module = ./module.nix;
      examples.qemu-coreboot-fbwhiptail-tpm1-hotp = {
        module = ./example.nix;
        description = ''
          Builds heads for the example qemu-coreboot-fbwhiptail-tpm1-hotp board, and makes the ROM image available
          at a fixed location, for testing it in a VM.
        '';
        tests.basic = import ./test.nix args;
      };
      links = {
        setup = {
          text = "Flashing & configuring Heads on hardware";
          url = "https://osresearch.net/Install-and-Configure";
        };
        emu-basic = {
          text = "Basic information for emulated testing";
          url = "https://osresearch.net/Emulating-Heads/";
        };
        emu-full = {
          text = "Documentationon how to test all functionality within a VM";
          url = "https://github.com/linuxboot/heads/blob/594abed8639b4f4a7fc9b7898d85eb48acbd0072/targets/qemu.md";
        };
      };
    };
  };
  # TODO: Referencing `pkgs` here is currently causing eval issues all over ngipkgs.
  # https://github.com/ngi-nix/ngipkgs/pull/773
  # Resolve this first before enabling this.
  /*
    binary = lib.attrsets.mapAttrs' (
      board: pkg: lib.attrsets.nameValuePair "${board}.rom" ({ data = "${pkg}/${pkg.passthru.romName}"; })
    ) (lib.attrsets.filterAttrs (_: lib.attrsets.isDerivation) pkgs.heads);
  */
}
