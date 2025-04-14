{
  sources,
  ...
}:
let
  swtpmDir = "/root/heads-swtpm";
  swtpmSocket = "${swtpmDir}/socket";
in
{
  name = "Heads-qemu-coreboot-fbwhiptail-tpm1-hotp";

  nodes = {
    machine =
      { pkgs, ... }:
      {
        imports = [
          "${sources.inputs.nixpkgs}/nixos/tests/common/x11.nix"
          sources.modules.ngipkgs
          sources.modules.programs.heads
          sources.examples.Heads.qemu-coreboot-fbwhiptail-tpm1-hotp
        ];

        environment.systemPackages = [
          # Adapted from qemu boards' `run` target:
          # https://github.com/linuxboot/heads/blob/594abed8639b4f4a7fc9b7898d85eb48acbd0072/targets/qemu.mk#L84
          (pkgs.writeShellApplication {
            name = "heads-setup-swtpm";
            runtimeInputs = with pkgs; [ swtpm ];
            text = ''
              mkdir -p "${swtpmDir}"
              exec swtpm socket \
                --tpmstate dir="${swtpmDir}" \
                --flags "startup-clear" \
                --terminate \
                --ctrl type=unixio,path="${swtpmSocket}"
            '';
          })
          (pkgs.writeShellApplication {
            name = "heads-run-qemu";
            runtimeInputs = with pkgs; [ qemu ];
            text = ''
              qemuDir="$HOME/heads-qemu"
              qemuRootDisk="$qemuDir"/root.qcow2
              qemuUsbFd="$qemuDir"/usb_fs.raw

              mkdir -p "$qemuDir"

              if [ ! -f "$qemuRootDisk" ]; then
                qemu-img create -f qcow2 "$qemuRootDisk" 4G
              fi

              if [ ! -f "$qemuUsbFd" ]; then
                dd if=/dev/zero of="$qemuUsbFd" bs=1M count=256 >/dev/null
                mkfs.vfat "$qemuUsbFd"
              fi

              exec qemu-system-x86_64 \
                -drive file="$qemuRootDisk",if=virtio \
                --machine q35,accel=kvm:tcg \
                -rtc base=utc \
                -smp 1 \
                -vga std \
                -m 256M \
                -serial stdio \
                --bios /etc/qemu-coreboot-fbwhiptail-tpm1-hotp.rom \
                -object rng-random,filename=/dev/urandom,id=rng0 \
                -device virtio-rng-pci,rng=rng0 \
                -netdev user,id=u1 -device e1000,netdev=u1 \
                -chardev socket,id=chrtpm,path="${swtpmSocket}" \
                -tpmdev emulator,id=tpm0,chardev=chrtpm \
                -device tpm-tis,tpmdev=tpm0 \
                -device qemu-xhci,id=usb \
                -device usb-tablet \
                -drive file="$qemuUsbFd",if=none,id=usb-fd-drive,format=raw \
                -device usb-storage,bus=usb.0,drive=usb-fd-drive
            '';
          })
        ];
      };
  };

  enableOCR = true;

  testScript =
    { nodes, ... }:
    ''
      start_all()
      machine.wait_for_x()

      # Start SWTPM in background
      machine.succeed("heads-setup-swtpm >&2 &")

      # Wait for socket
      machine.wait_for_file("${swtpmSocket}")

      # Start running the ROM
      machine.succeed("heads-run-qemu >&2 &")

      # Wait for Linux boot to happen (we don't have a bootable OS, so look for those messages)
      machine.wait_for_console_text("mount_boot")
      machine.sleep(20) # Start OCR when there's actually something on-screen
      machine.wait_for_text(r"(No bootab[lI|]e|defau[lI|]t boot device|proceed|new boot device|USB|main menu|recovery she[lI|][lI|])")
      machine.screenshot("1-heads-no-os")

      # Try to get to main menu
      machine.send_key("down")
      machine.send_key("down")
      machine.sleep(3)
      machine.send_key("ret")
      machine.wait_for_console_text("show_main_menu")
      machine.sleep(20) # Start OCR when there's actually something on-screen
      machine.wait_for_text(r"(Defau[lI|]t boot|TOTP|HOTP|Options|System [lI|]nfo|Power Off)")
      machine.screenshot("2-heads-main-menu")
    '';
}
