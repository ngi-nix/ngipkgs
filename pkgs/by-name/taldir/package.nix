{
  fetchgit,
  lib,
  recutils,
  buildGoModule,
}:
buildGoModule {
  pname = "taldir";
  version = "0-unstable-2024-02-18";

  src = fetchgit {
    url = "https://git.taler.net/taldir.git";
    rev = "9c5230f64d16d46c000c6d4f5842170c51b697ce";
    hash = "sha256-Ri0R7kxP/FitBRKtrM48Cbks63mqpXsRc3r98M0sMus=";
  };

  postPatch = ''
    cp ${./go.sum} go.sum
  '';

  vendorHash = "sha256-yN8CiRK7cS4bHndOcu+/HI50PDOG+5x/t2kxlIt+5Mk=";

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

  subPackages = [
    "cmd/taldir-cli"
    "cmd/taldir-server"
  ];

  # dial error (dial tcp [::1]:5432: connect: connection refused)
  doCheck = false;

  meta = {
    homepage = "https://git.taler.net/taldir.git";
    description = "Directory service to resolve wallet mailboxes by messenger addresses.";
    license = lib.licenses.agpl3Plus;
  };
}
