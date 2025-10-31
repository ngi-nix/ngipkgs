# Modified from: https://github.com/imincik/nix-utils/blob/f0e102cc767951364949cbb9965d2d7120ea4fa7/maintainer-packages.nix

# List packages maintained by the Nix@NGI team in Nixpkgs.

## USAGE:

# Nixpkgs associated with NGIpkgs tag/revision:
#
# nix eval --json -f maintainers/metrics-maintainer.nix packages --argstr rev 25.02 | jq '[.. | objects | select(has("name")) | .name]'

# Latest Nixpkgs:
#
# nix eval --json -f maintainers/metrics-maintainer.nix packages --argstr rev nixpkgs | jq '[.. | objects | select(has("name")) | .name]'

{
  rev ? "main",
  ngipkgs ? import (fetchTarball "https://github.com/ngi-nix/ngipkgs/tarball/${rev}") { },

  nixpkgs ?
    if rev == "nixpkgs" then
      (fetchTarball "https://github.com/NixOS/nixpkgs/tarball/master")
    else
      ngipkgs.sources.nixpkgs,

  pkgs ? import nixpkgs {
    config.allowBroken = true;
    config.allowUnfree = true;
  },

  team ? "ngi",

  showBroken ? true, # show broken packages
}:

let
  inherit (pkgs.lib.debug) traceVal;
  inherit (pkgs.lib)
    attrValues
    elem
    filterAttrsRecursive
    flatten
    isAttrs
    isDerivation
    map
    mapAttrs
    ;

  myTeam = pkgs.lib.teams.${team};

  isMaintainedBy =
    pkg:
    elem myTeam (
      pkg.meta.teams or [ ] ++ (flatten (map (x: x.members or [ ]) (pkg.meta.teams or [ ])))
    );

  isDerivationRobust =
    pkg:
    let
      result = builtins.tryEval (isDerivation pkg);
    in
    if result.success then result.value else false;

  brokenFilter =
    pkg:
    let
      isBroken = pkg.meta.broken;
    in
    if showBroken then
      true
    else if isBroken == false then
      true
    else
      false;

  isPkgSet =
    pkg:
    let
      result = builtins.tryEval ((isAttrs pkg) && (pkg.recurseForDerivations or false));
    in
    if result.success then result.value else false;

  recursePackageSet =
    pkgSetName: pkgs:
    mapAttrs (
      name: pkg:
      if isDerivationRobust pkg then
        if isMaintainedBy pkg && brokenFilter pkg then
          {
            name = "${if pkgSetName != null then pkgSetName + "." + name else name}";
            update-script = pkg ? passthru.updateScript;
          }
        else
          null
      else if isPkgSet pkg then
        recursePackageSet name pkg
      else
        null
    ) pkgs;
in
{
  packages = attrValues (
    filterAttrsRecursive (n: v: v != null || v != { }) (recursePackageSet null pkgs)
  );
}
