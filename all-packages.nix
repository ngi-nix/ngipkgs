{ callPackage, ... }:

{
  libgnunetchat = callPackage ./pkgs/libgnunetchat { };
  gnunet-messenger-cli = callPackage ./pkgs/gnunet-messenger-cli { };
  liberaforms = callPackage ./pkgs/liberaforms { };
  #liberaforms-env = callPackage ./pkgs/liberaforms { };
  default = throw "NGIPkgs does not export any default package.";
}
