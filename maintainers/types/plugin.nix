{
  lib,
  ...
}:

let
  inherit (lib)
    types
    mkOption
    ;
in

# TODO: plugins are actually component *extensions* that are of component-specific type,
#       and which compose in application-specific ways defined in the application module.
#       this also means that there's no fundamental difference between programs and services,
#       and even languages: libraries are just extensions of compilers.
# TODO: implement this, now that we're using the module system
types.anything
