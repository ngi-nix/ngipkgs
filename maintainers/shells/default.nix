{
  lib,
  pkgs,
  sources,
  callPackage,
  overrideScope,

  # toplevel attributes
  formatter,
  ...
}:
let
  devshell = import sources.devshell { nixpkgs = pkgs; };

  devshellEnv = lib.makeExtensible (final: {
    name = "devshell";

    motd = ''

      {33}❄️ Welcome to NGIpkgs{reset}

      {85}📖 Docs: https://ngi.nixos.org/manuals 💬 Chat: #ngipkgs:nixos.org (Matrix){reset}
      $(type -p menu &>/dev/null && menu)

      {123}Tip:{reset} DEVSHELL_NO_MOTD=1 will disable this welcome message
    '';

    generalCategory = "[general commands]";

    mkAliases =
      {
        aliases,
        category ? final.generalCategory,
      }:
      lib.mapAttrsToList (name: value: {
        inherit name;
        command = value.cmd;
        # fallback to category and thus generalCategory if not specified
        category = value.category or category;
        # fallback to `cmd` if help is not specified
        help = value.help or value.cmd;
      }) aliases;

    mapCommands =
      category: packages:
      builtins.map (p: {
        inherit category;
        package = p;
      }) packages;

    commands = (final.mapCommands "formatter" final.formatters) ++ final.defaultCmds ++ final.aliases;

    packages = [
      (callPackage ./packages/nixdoc-to-github.nix { })
    ]; # packages are hidden in the menu

    packagesFrom = [ ]; # inputsFrom equivalent, are hidden in the menu

    finalPackage = final.eval.shell;

    eval = devshell.eval {
      configuration = (
        lib.filterAttrs (
          name: value:
          # filter only the valid args for devshell.eval
          builtins.elem name [
            "name"
            "motd"
            "commands"
            "packages"
            "packagesFrom"

            "devshell"
            "bash"
          ]
        ) final
      );
    };

    # devshell accepts no shellHook but we can use the extra or interactive blocks it provides
    # also can use devshell.startup.* or devshell.interactive.* with lib.noDepEntry
    devshell.startup.bash_extra_more = lib.noDepEntry final.shellHook;

    # disables devshell to change the prompt in anyway
    devshell.interactive.PS1 = lib.noDepEntry "";

    # default empty shellHook, implies no override
    shellHook = "";

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
    # given a shell get the "packages" from the shell
    commandsFrom' = shell: lib.foldl' (sum: drv: sum ++ (final.inputsOf drv)) [ ] [ shell ];

    # Include all formatter packages. Format with:
    # $ treefmt
    # $ nix fmt
    formatters = final.commandsFrom' formatter.shell;

    # Aliases are wrapper commands which will run the specified `cmd`
    # `help` exists to customise the menu entry
    aliases = final.mkAliases {
      aliases = {
        reload.cmd = "direnv reload";
        reload.help = "reload the direnv shell";

        # Adds a `shell` wrapper/alias pointing to the currently active shell
        shell.cmd = "${final.name} \"$@\"";
        shell.help = "run any command via the devshell, see shell -h";

        gen-project-md.cmd = "set -x; nix-shell --run nixdoc-to-github";
        gen-project-md.help = "convert NGI-project types' nixdoc to GitHub markdown";
        gen-project-md.category = "maintainance";
      };
    };
    # requires a different name as "commands" can't be used
    # because unlike other attributes "commands" needs to be built from a few `final` attributes
    defaultCmds =
      let
        src = ./commands;

        files = lib.fileset.toList (
          lib.fileset.intersection (lib.fileset.gitTracked ../..) (
            lib.fileset.fileFilter (file: file.hasExt "nix") src
          )
        );

        callPackage' = (overrideScope (_: _: { devshellEnv = final; })).callPackage;

        # ./commands/<category>/<command.nix> - [category]
        # ./commands/<command.nix>            - [[genral commands]]
        getCategory =
          file:
          let
            parentDir = dirOf file;
          in
          if parentDir == src then final.generalCategory else baseNameOf parentDir;

        groupedFiles = lib.groupBy getCategory files;
      in
      lib.concatLists (
        lib.mapAttrsToList (
          category: categoryFiles:
          final.mapCommands category (builtins.map (path: callPackage' path { }) categoryFiles)
        ) groupedFiles
      );
  });
in
devshellEnv
