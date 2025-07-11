{
  sources,
  pkgs,
  lib,
  ...
}:
{
  name = "nyxt demo";

  nodes = {
    machine =
      { pkgs, ... }:
      {
        imports = [
          sources.modules.ngipkgs
          sources.modules.programs.nyxt
          sources.examples.nyxt.basic
          # sets up x11 with autologin
          "${sources.inputs.nixpkgs}/nixos/tests/common/x11.nix"
        ];

        # not enough memory for the allocation
        virtualisation.memorySize = 8192;

        environment.systemPackages = with pkgs; [
          xdotool
        ];
      };
  };

  enableOCR = true;

  testScript =
    { nodes, ... }:
    ''
      start_all()
      machine.wait_for_x()

      # start nyxt
      machine.execute("nyxt >&2 &")

      machine.send_key("ctrl+l")
      machine.send_chars("google.com\n")

      machine.wait_for_text("Google")
    '';
}
