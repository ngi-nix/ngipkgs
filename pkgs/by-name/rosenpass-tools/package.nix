{ pkgs, lib, ... }:
lib.recursiveUpdate pkgs.rosenpass-tools {
  meta.ngi = {
    project = "Rosenpass";
    main = false;
  };
}
