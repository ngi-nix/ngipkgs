{
  pkgs,
  lib,
}:
lib.makeScope pkgs.newScope (self: {
  rest-api = self.callPackage ./rest-api { };
})
