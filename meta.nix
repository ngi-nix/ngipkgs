{
  lib,
  pkgs,
  self,
  options
}:
pkgs.runCommand "meta" {}
''
  mkdir $out
  cp ${(pkgs.nixosOptionsDoc { inherit options; }).optionsJSON}/share/doc/nixos/options.json $out
  cp ${pkgs.writeText "meta.json" (builtins.toJSON (builtins.mapAttrs (_: value: value.meta) self))} $out/meta.json
  ${lib.concatLines (lib.mapAttrsToList (name: value: "echo '{\"${name}\": ${builtins.toJSON value}}' >> $out/derivations.json") self)}
  cd $out 
  ${lib.getExe pkgs.jq} -n -f ${./data.jq} > data.json
''