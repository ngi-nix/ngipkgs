{#Contributor_How_to_develop_a_package_using_CAcert}
# How to develop a package using CAcert?

Some packages, especially those to update other packages,
may need to access resources over TLS outside the usual `fetch*` utilities.
To be used TLS requires to specify a pool of certificate authorities (CA),
those usually come from `pkgs.cacert`, and can provisionned like this:
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
