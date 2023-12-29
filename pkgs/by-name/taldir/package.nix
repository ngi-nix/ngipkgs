{
  fetchgit,
  lib,
  recutils,
  buildGoModule,
}:
buildGoModule {
  pname = "taldir";
  version = "0-unstable-2022-07-19";

  src = fetchgit {
    url = "https://git.taler.net/taldir.git";
    rev = "4a63cc4b6c6846f6c1e3188124a691d564a80664";
    hash = "sha256-M1+JsqX5sUKKi9fOd3Lh4G2G7Z1mCVqZS8Nro6nmfUY=";
  };

  postPatch = ''
    cp ${./go.mod} go.mod
    cp ${./go.sum} go.sum
  '';

  vendorHash = "sha256-+SJtKjAvDtWzRy6ituwFnyRUCbSsUs0uOEnUOMi51vQ=";

  nativeBuildInputs = [
    recutils
  ];

  # From Makefile
  preBuild = ''
    mkdir -p internal/gana

    pushd third_party/gana/gnu-taler-error-codes
    make taler_error_codes.go
    popd

    cp third_party/gana/gnu-taler-error-codes/taler_error_codes.go internal/gana/
  '';

  # dial error (dial tcp [::1]:5432: connect: connection refused)
  doCheck = false;

  meta = {
    homepage = "https://git.taler.net/taldir.git";
    description = "Directory service to resolve wallet mailboxes by messenger addresses.";
    license = lib.licenses.agpl3Plus;
  };
}
