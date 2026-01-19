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
    # formatters = final.commandsFrom formatter.shell;
    formatters = (builtins.attrValues formatter.eval.config.build.programs) ++ [ formatter.package ];

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
    defaultCmds =
      let
        files = lib.fileset.toList (
          lib.fileset.intersection (lib.fileset.gitTracked ../..) (
            lib.fileset.fileFilter (file: file.hasExt "nix") ./commands
          )
        );
        callPackage' = lib.callPackageWith (pkgs // { inherit nixdoc-to-github ngipkgs; });
      in
      final.mapCommands "commands" (builtins.map (path: callPackage' path { }) files);
  });
in
devshellArgs
