{
  lib,
  pkgs,
  devshell,
  nixdoc-to-github,

  # toplevel attributes
  ngipkgs,
  formatter,
  ...
}:
let
  devshellArgs = lib.makeExtensible (final: {

    generalCategory = "[general commands]";

    mkAliases =
      {
        aliases,
        category ? final.generalCategory,
      }:
      lib.mapAttrsToList (name: value: {
        inherit name;
        command =
          if name == "shell" then
            # if `shell`, forward the args to underlying shell
            "${value.cmd} \"$@\""
          else
            value.cmd;
        help =
          if name == "shell" then
            "run any command via the devshell, see shell -h"
          else
            # fallback to `cmd` if help is not specified
            (value.help or value.cmd);
      }) aliases;

    mapCommands =
      category: packages:
      builtins.map (p: {
        inherit category;
        package = p;
      }) packages;

    # from numtide/devshell, copyright Numtide, MIT licensed
    # Returns a list of all the input derivation ... for a derivation.
    inputsOf =
      drv:
      lib.filter lib.isDerivation (
        (drv.buildInputs or [ ])
        ++ (drv.nativeBuildInputs or [ ])
        ++ (drv.propagatedBuildInputs or [ ])
        ++ (drv.propagatedNativeBuildInputs or [ ])
      );

    # from numtide/devshell, copyright Numtide, MIT licensed
    commandsFrom = shell: lib.foldl' (sum: drv: sum ++ (final.inputsOf drv)) [ ] [ shell ];

    # The following are args to be passed to devshell.mkShell
    name = "devshell";
    motd = ''

      {33}❄️ Welcome to NGIpkgs{reset}

      {85}🛠️ Docs: 📖 https://ngi.nixos.org/docs/contributing 💬 Chat: #ngipkgs:nixos.org (Matrix){reset}
      $(type -p menu &>/dev/null && menu)
    '';
    commands =
      (final.mapCommands "formatter" final.formatters)
      ++ final.defaultCmds
      ++ final.aliases
      ++ (final.mkAliases {
        # Adds a `shell` wrapper/alias pointing to the currently active shell
        aliases.shell.cmd = final.name;
      });
    packages = [ ]; # packages are hidden in the menu
    packagesFrom = [ ]; # inputsFrom equivalent, are hidden in the menu
    # End devshell.mkShell args

    _devshell = devshell.mkShell (
      lib.filterAttrs (
        name: value:
        # filter only the valid args for devshell.mkShell
        builtins.elem name [
          "name"
          "motd"
          "commands"
          "packages"
          "packagesFrom"
        ]
      ) final
    );

    finalPackage =
      if (final.shellHook != "") then
        # allow shellHook overriding by embedding into another shell
        # FIXME(phanirithvij): possible to fix this in numtide/devshell, a shellHook argument to mkShell
        pkgs.mkShellNoCC {
          inherit (final) name;
          shellHook = ''
            source ${final._devshell.hook}/nix-support/setup-hook
            ${final.shellHook}
          '';
          packages = [ final._devshell ];
        }
      else
        # use the minimal numtide shell if shellHook override is not required
        final._devshell;

    # default empty shellHook, implies no override
    shellHook = "";

    # Include all formatter packages. Format with:
    # $ treefmt
    # $ nix fmt
    formatters = final.commandsFrom formatter.shell;

    # Aliases are wrapper commands which will run the specified `cmd`
    # `help` exists to customise the menu entry
    aliases = final.mkAliases {
      aliases = {
        reload.cmd = "direnv reload";
        welcome.cmd = "direnv allow";
        welcome.help = "shows the welcome message again";
      };
    };

    # requires a different name as "commands" can't be used
    # because unlike other attributes "commands" needs to be built from a few `final` attributes
    defaultCmds = final.mapCommands "commands" ([
      # live overview watcher
      (
        (pkgs.devmode.override {
          buildArgs = "-A overview --show-trace -v";
        }).overrideAttrs
        { meta.description = "watches files for changes and live reloads the overview"; }
      )

      (pkgs.writeShellApplication {
        # TODO: have the program list available tests
        # TODO: system agnostic
        name = "ngipkgs-test";
        text = ''
          export pr="$1"
          export proj="$2"
          export test="$3"
          # remove the first args and feed the rest (for example flags)
          export args="''${*:4}"

          nix build --override-input nixpkgs \
            "github:NixOS/nixpkgs?ref=pull/$pr/merge" \
            .#checks.x86_64-linux.projects/"$proj"/nixos/tests/"$test" "$args"
        '';
        meta.description = "runs a NGIpkgs check based off an open pr in nixpkgs";
      })

      # NOTE: currently, this only works with flakes, because `nix-update` can't
      # find `maintainers/scripts/update.nix` otherwise
      #
      # nix-shell --run 'update PACKAGE_NAME --use-update-script'
      (pkgs.writeShellApplication {
        name = "update";
        runtimeInputs = with pkgs; [ nix-update ];
        text = ''
          package=$1; shift # past value
          nix-update --flake --use-update-script "$package" "$@"
        '';
        meta.description = "updates an NGIpkgs package (nix with flakes supported required)";
      })

      (pkgs.writeShellApplication {
        name = "update-all";
        runtimeInputs = with pkgs; [ nix-update ];
        meta.description = "updates all the NGIpkgs packages (nix with flakes supported required)";
        text =
          let
            skipped-packages = [
              "atomic-browser" # -> atomic-server
              "atomic-cli" # -> atomic-server
              "firefox-meta-press" # -> meta-press
              "inventaire" # -> inventaire-client
              "kbin" # -> kbin-backend
              "kbin-frontend" # -> kbin-backend
              "pretalxFull" # -> pretalx
              # FIX: needs custom update script
              "marginalia-search"
              "peertube-plugin-livechat"
              "_0wm-server"
              # FIX: dream2nix
              "liberaforms"
              # FIX: package scope
              "bigbluebutton"
              "heads"
              "lean-ftl"
              # FIX: don't update `sparql-queries` if there is no version change
              "inventaire-client"
              # fetcher not supported
              "libervia-backend"
              "libervia-desktop-kivy"
              "libervia-media"
              "libervia-templates"
              # broken package
              "libresoc-nmigen"
              "libresoc-verilog"
              # other issues
              "kazarma"
              "anastasis"
            ];
            update-packages = with lib; filter (x: !elem x skipped-packages) (attrNames ngipkgs);
            update-commands = lib.concatMapStringsSep "\n" (package: ''
              if ! nix-update --flake --use-update-script "${package}" "$@"; then
                echo "${package}" >> "$TMPDIR/failed_updates.txt"
              fi
            '') update-packages;
          in
          # bash
          ''
            TMPDIR=$(mktemp -d)

            echo -n> "$TMPDIR/failed_updates.txt"

            ${update-commands}

            if [ -s "$TMPDIR/failed_updates.txt" ]; then
              echo -e "\nFailed to update the following packages:"
              cat "$TMPDIR/failed_updates.txt"
            else
              echo "All packages updated successfully!"
            fi
          '';
      })

      # nix-shell --run nixdoc-to-github
      (
        (nixdoc-to-github.lib.nixdoc-to-github.run {
          description = "NGI Project Types";
          category = "";
          file = "${toString ../../projects/types.nix}";
          output = "${toString ../../maintainers/docs/project.md}";
        }).overrideAttrs
        {
          meta.description = "convert nixdoc output to GitHub markdown";
        }
      )
    ]);
  });
in
devshellArgs
