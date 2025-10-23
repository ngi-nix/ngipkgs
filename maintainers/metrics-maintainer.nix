/*
  Count how many derivations are maintained by the Nix@NGI team in Nixpkgs.

  Usage:

  # NGIpkgs commit
  nix eval -f ./metrics-maintainer.nix metrics.maintained --argstr team ngi --argstr rev 4d6c17428e6e32f474e8fc75a87b8f9bd6c6356d

  # release tag
  nix eval -f ./metrics-maintainer.nix metrics.maintained --argstr team ngi --argstr rev 25.02

  # branch
  nix eval -f ./metrics-maintainer.nix metrics.maintained --argstr team ngi --argstr rev main

  # latest Nixpkgs
  nix eval -f ./metrics-maintainer.nix metrics.maintained --argstr team ngi --arg nixpkgs 'fetchTarball "https://github.com/NixOS/nixpkgs/tarball/master"'
*/
{
  rev ? "main",
  ngipkgs ? import (fetchTarball "https://github.com/ngi-nix/ngipkgs/tarball/${rev}") { },
  nixpkgs ? ngipkgs.sources.nixpkgs,
  pkgs ? import nixpkgs { },
  lib ? ngipkgs.lib,
  team ? null,
  maintainer ? null,
}:
let
  atom =
    if team != null then
      lib.teams.${team}
    else if maintainer != null then
      lib.maintainers.${maintainer}
    else
      throw "Please specify a team or a maintainer to check";

  evalFilterAttrs = attrs: lib.filterAttrs (name: value: (builtins.tryEval value).success) attrs;

  # Count the total number of elements inside an attrs
  countAttrs =
    attrs:
    lib.foldlAttrs
      (
        acc: ScopeName: scopeValue:
        let
          names = lib.attrNames scopeValue;
        in
        {
          sum = acc.sum + (lib.length names);
          names =
            acc.names ++ (map (name: if ScopeName != "pkgs" then "${ScopeName}.${name}" else name) names);
        }
      )
      {
        sum = 0;
        names = [ ];
      }
      attrs;

  # Derivation scopes may be duplicated, so we explicitly specify the ones we need.
  scopes = {
    inherit (pkgs)
      pkgs
      haskellPackages
      python3Packages
      ocamlPackages
      kdePackages
      beamPackages
      nodePackages
      elmPackages
      dotnetPackages
      rustPackages
      luaPackages
      phpPackages
      rubyPackages
      javaPackages
      vscode-extensions
      vimPlugins
      ;
  };
in
rec {
  maintained = lib.mapAttrs (
    _: scope:
    lib.filterAttrs (
      _: drv: (lib.elem atom (drv.meta.teams or [ ])) || (lib.elem atom (drv.meta.maintainers or [ ]))
    ) (evalFilterAttrs scope)
  ) scopes;

  maintained-with-update-script = lib.mapAttrs (
    _: scope: lib.filterAttrs (_: drv: drv ? passthru.updateScript) scope
  ) maintained;
  maintained-without-update-script = lib.mapAttrs (
    _: scope: lib.filterAttrs (_: drv: !drv ? passthru.updateScript) scope
  ) maintained;

  metrics = {
    maintained = countAttrs maintained;
    maintained-with-update-script = countAttrs maintained-with-update-script;
    maintained-without-update-script = countAttrs maintained-without-update-script;
  };
}
