{
  sources,
  pkgs,
  lib,
  ...
}:

let
  # These are files that the service would download from the internet on startup
  # To allow testing within a sandboxed environment, provide pre-downloaded versions
  # Some of the data exceeds Git(Hub?) limits without LFS, so need to uncompress first
  downloadedData = import ./test-data/default.nix;
  unpackedData =
    pkgs.runCommand "test-data"
      {
        nativeBuildInputs = with pkgs; [
          gnutar
          xz
        ];
      }
      ''
        xzcat ${downloadedData.src} | tar -xvf-
        mv data $out
      '';
in
{
  name = "marginalia-search";

  nodes = {
    server =
      { config, ... }:
      {
        imports = [
          sources.modules.ngipkgs
          sources.modules.services.marginalia-search
          sources.examples.MarginaliaSearch.base
        ];

        # Running into memory limits with the default
        virtualisation.memorySize = 2048;

        services.xserver = {
          enable = true;
          windowManager.icewm.enable = true;
        };

        services.displayManager = {
          defaultSession = "none+icewm";
          autoLogin = {
            enable = true;
            user = "root";
          };
        };

        # lightdm by default doesn't allow auto login for root, which is
        # required by some nixos tests. Override it here.
        security.pam.services.lightdm-autologin.text = lib.mkForce ''
          auth     requisite pam_nologin.so
          auth     required  pam_succeed_if.so quiet
          auth     required  pam_permit.so

          account  include   lightdm

          password include   lightdm

          session  include   lightdm
        '';

        environment.systemPackages = with pkgs; [
          firefox
        ];

        systemd.tmpfiles.settings =
          let
            dirSettings = {
              user = "marginalia-search";
              group = "marginalia-search";
              mode = "0700";
            };
          in
          {
            "99-marginalia-test-setup" =
              {
                "/var/lib/marginalia-search".d = dirSettings;
                "/var/lib/marginalia-search/data".d = dirSettings;
              }
              // (builtins.listToAttrs (
                builtins.map (name: {
                  name = "/var/lib/marginalia-search/data/${name}";
                  value = {
                    L.argument = "${unpackedData}/${name}";
                  };
                }) downloadedData.names
              ));
          };
      };
  };

  testScript =
    { nodes, ... }:
    ''
      start_all()

      machine.wait_for_unit("marginalia-search.service")

      machine.wait_for_console_text("Listening on 127.0.0.1:7000")

      machine.wait_for_x()
      machine.succeed("firefox http://127.0.0.1:7000 >&2 &")
      # Note: Firefox doesn't use a regular "-" in the window title, but "—" (Hex: 0xe2 0x80 0x94)
      machine.wait_for_window("Control Service — Mozilla Firefox")

      # Let it finish rendering the page
      machine.sleep(5)
      machine.screenshot("marginalia-control-GUI")
    '';
}
