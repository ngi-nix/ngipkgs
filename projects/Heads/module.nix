{
  config,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.programs.heads;
in
{
  # Note: Heads produces ROM images intended to be flashed onto real hardware.
  # This module only exists to expose the build images at fixed locations.
  options.programs.heads = {
    enable = lib.options.mkEnableOption "symlinking of the selected Heads boards' ROMs under /etc/heads";
    boards = lib.options.mkOption {
      description = ''
        Heads board targets that should be built & symlinked.

        Note: Using this option, you can specify boards that aren't currently provided or tested by NGIpkgs.
        This will cause a heavy build process to run on your system, which may end in a build failure.
      '';
      type = lib.types.listOf lib.types.str;
      default = pkgs.heads.allowedBoards;
    };
  };

  config = lib.mkIf cfg.enable {
    environment.etc =
      let
        headsPkgs = pkgs.heads.generateBoards cfg.boards;
      in
      lib.attrsets.listToAttrs (
        lib.lists.map (board: {
          name = "heads/${board}.rom";
          value = {
            source = "${headsPkgs.${board}}/${headsPkgs.${board}.passthru.romName}";
          };
        }) cfg.boards
      );
  };
}
