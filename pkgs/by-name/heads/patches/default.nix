{
  lib,
  ...
}@args:

lib.attrsets.concatMapAttrs (
  name: type:
  if type == "directory" then
    {
      "${name}" = import (./. + "/${name}") args;
    }
  else
    { }
) (builtins.readDir ./.)
