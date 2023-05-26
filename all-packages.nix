{ callPackage, ... }:

{
  libgnunetchat = callPackage ./pkgs/libgnunetchat { };
  gnunet-messenger-cli = callPackage ./pkgs/gnunet-messenger-cli { };
  default = throw "NGIPkgs does not export any default package.";
}
