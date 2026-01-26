{
  lib,
  callPackage,
  unstableGitUpdater,
}:
let
  root = ./.;
  updateScript = [
    ./update.sh
    (unstableGitUpdater { })
  ];

  call =
    name:
    lib.recursiveUpdate (callPackage (root + "/${name}") { }) {
      passthru.updateScript = updateScript;
    };

  plugins = lib.pipe root [
    builtins.readDir
    (lib.filterAttrs (_: type: type == "directory"))
    (lib.mapAttrs (name: _: call name))
  ];
in
lib.recurseIntoAttrs plugins
