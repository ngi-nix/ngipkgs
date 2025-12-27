(Contributor_How_to_develop_a_package_using_TLS)=
# How to develop a package using TLS?

`pkgs.cacert` can be used like this:
```nix
{ stdenv, cacert }:
stdenv.mkDerivation {
  nativeBuildInputs = [ cacert ];
  preConfigure = ''
    export GIT_SSL_CAINFO=$NIX_SSL_CERT_FILE
    export SSL_CERT_FILE=$NIX_SSL_CERT_FILE
  '';
};
```
