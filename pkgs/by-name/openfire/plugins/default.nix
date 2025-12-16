{
  pkgs,
  lib,
}:
lib.makeScope pkgs.newScope (
  self:
  let
    callPackage = self.newScope {
      fetchOpenfirePlugin = self.callPackage ./fetch-openfire-plugin.nix { };
    };
  in
  {
    galene = callPackage ./galene { };
    rest-api = callPackage ./rest-api { };
  }
)
