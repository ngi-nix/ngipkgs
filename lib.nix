{lib}: {
  # Take an attrset of arbitrary nesting and make it flat
  # by concatenating the nested names with the given separator.
  flattenAttrs = separator: let
    f = path: lib.concatMapAttrs (flatten path);
    flatten = path: name: value:
      if lib.isAttrs value
      then f (path + name + separator) value
      else {${path + name} = value;};
  in
    f "";
}
