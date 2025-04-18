{
  self ? import ./. { },
  sources ? self.sources,
  system ? self.system,
  pkgs ? self.pkgs,
  lib ? self.lib,
}:
self.shell
