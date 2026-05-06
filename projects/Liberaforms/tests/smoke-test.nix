{
  lib,
  hostPkgs ? pkgs,
  pkgs,
  sources,
  ...
}:
let
  python = hostPkgs.python3.withPackages (
    ps: with ps; [
      requests
      playwright
    ]
  );

  runScript = "${lib.getExe python} ${./basic_interaction_test.py}";

  run-liberaforms-test = hostPkgs.writeShellScriptBin "run-liberaforms-test" ''
    set -euo pipefail

    export PLAYWRIGHT_BROWSERS_PATH=${hostPkgs.playwright-driver.browsers}
    export PLAYWRIGHT_SKIP_BROWSER_DOWNLOAD=1

    # check if in a interactive terminal session
    if [ -t 1 ]; then
      export HEADFUL=''${HEADFUL:-1}
      export PWDEBUG=''${PWDEBUG:-0}
      export DISPLAY=''${DISPLAY:-:0}
      if [ "$(id -u)" = "0" ] && [ -d "/home/alice" ]; then
        runuser -u alice \
          -w DISPLAY,HEADFUL,PWDEBUG,PLAYWRIGHT_BROWSERS_PATH,PLAYWRIGHT_SKIP_BROWSER_DOWNLOAD \
          -- ${runScript}
      else
        export BASE_URL="http://127.0.0.1:3939"
        ${runScript}
      fi
    else
      cat <<'EOF' | tee >(systemd-cat -t liberaforms-smoke-test)
    ================================================================================
    NOTE: The liberaforms smoke-test can be run interactively either inside the vm or on the host
      - First, run `nix-build -A projects.Liberaforms.tests.smoke-test.driverInteractive` and `./result/bin/nixos-test-driver`
        - Run `start_all()` inside the repl
      - Then in a new terminal run `nix-build -A projects.Liberaforms.tests.smoke-test.driverInteractive.interactive-script`
        and `./result/bin/run-liberaforms-test` to run the full test interactively
        - Or prepend to the above command `env PWDEBUG=1` to show the playwright inspector to debug
    ================================================================================
    EOF

      echo "Starting smoke test..." | systemd-cat -t liberaforms-smoke-test
      ${runScript} 2>&1 | tee >(systemd-cat -t liberaforms-smoke-test)
    fi
  '';
in
{
  name = "liberaforms";

  passthru.interactive-script = run-liberaforms-test;

  nodes.machine =
    {
      lib,
      pkgs,
      config,
      ...
    }:
    {
      imports = [
        sources.modules.ngipkgs
        sources.modules.services.liberaforms
        sources.examples.Liberaforms.basic
      ];

      services.mailpit.instances.default = {
        listen = "0.0.0.0:8025";
        smtp = "0.0.0.0:1025";
      };

      services.liberaforms = {
        rootEmail = "admin@example.org";
        smtp = {
          enable = true;
          host = "127.0.0.1";
          port = 1025;
          noreply = "noreply@localhost";
        };
      };

      networking = {
        firewall.allowedTCPPorts = [ config.services.nginx.defaultHTTPListenPort ];
        hostName = "liberaforms";
        domain = "local";
      };

      environment.systemPackages = [
        python
        run-liberaforms-test
      ];

      virtualisation.memorySize = lib.mkForce 4096;
      virtualisation.cores = 4;
    };

  testScript =
    { nodes, ... }:
    ''
      import os
      start_all()

      machine.wait_for_unit("liberaforms.service")
      machine.wait_for_open_port(80)
      machine.wait_for_open_port(5000)

      machine.succeed("curl -q --fail http://localhost")

      machine.succeed("run-liberaforms-test")

      out_dir = os.environ.get("out", os.getcwd())
      machine.copy_from_vm("/tmp/videos", out_dir)
    '';

  interactive.sshBackdoor.enable = true;
  interactive.nodes.machine =
    { config, ... }:
    let
      guestPorts = [
        80
        1025
        8025
      ];
      hostPorts = [
        3939
        1025
        8025
      ];
    in
    {
      imports = [
        (hostPkgs.path + "/nixos/tests/common/x11.nix")
        (hostPkgs.path + "/nixos/tests/common/user-account.nix")
      ];
      services.xserver.enable = true;
      test-support.displayManager.auto.user = "alice";

      virtualisation.forwardPorts = lib.zipListsWith (h: g: {
        from = "host";
        host.port = h;
        guest.port = g;
      }) hostPorts guestPorts;

      networking.firewall.allowedTCPPorts = guestPorts;
      networking.firewall.allowedUDPPorts = guestPorts;
    };
}
