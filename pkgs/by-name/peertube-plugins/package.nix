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
    (callPackage (root + "/${name}") { }).overrideAttrs (old: {
      passthru = old.passthru or { } // {
        inherit updateScript;
      };
    });

  plugins = lib.pipe root [
    builtins.readDir
    (lib.filterAttrs (_: type: type == "directory"))
    (lib.mapAttrs (name: _: call name))
  ];
in
lib.recurseIntoAttrs plugins
