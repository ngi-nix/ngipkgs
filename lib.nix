# Functions to lay on top of Nixpkgs' lib for convenience.
{lib}: let
  inherit
    (builtins)
    mapAttrs
    isAttrs
    concatStringsSep
    ;

  inherit
    (lib)
    attrByPath
    concatMapAttrs
    ;
in rec {
  # Takes an attrset of arbitrary nesting (attrset containing attrset)
  # and flattens it into an attrset that is *not* nested, i.e., does
  # *not* contain attrsets.
  # This is done by concatenating the names of nested values using a
  # separator.
  #
  # Type: flattenAttrs :: string -> [string] -> AttrSet -> AttrSet
  #
  # Example:
  #   flattenAttrs "~" ["1" "2"] { a = { b = "x"; }; c = { d = { e = "y"; }; }; f = "z"; }
  #   => { "1~2~a~b" = "x"; "1~2~c~d~e" = "y"; "1~2~f" = "z"; }
  flattenAttrs =
    # Separator to use to join names of different nesting levels.
    separator:
    # Prefix to be prepended to all names in the generated attrset,
    # as a list that is joined by the separator.
    prefix: let
      initPath =
        if prefix == []
        then ""
        else (concatStringsSep separator prefix) + separator;
      f = path:
        concatMapAttrs (
          name: value:
            if isAttrs value
            then f (path + name + separator) value
            else {${path + name} = value;}
        );
    in
      f initPath;

  flattenAttrsSlash = flattenAttrs "/" [];
  flattenAttrsDot = flattenAttrs "." [];

  mapAttrByPath = attrPath: default: mapAttrs (_: attrByPath attrPath default);
}
