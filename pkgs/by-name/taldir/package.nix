{
  lib,
  fetchgit,
  recutils,
  buildGoModule,
  unstableGitUpdater,
}:
buildGoModule (finalAttrs: {
  pname = "taldir";
  version = "1.0.5-unstable-2025-10-15";

  src = fetchgit {
    url = "https://git.taler.net/taldir.git";
    rev = "8fbc813afb14807dbc62c4c95402f282a8165f07";
    hash = "sha256-2tIS98MTPGTEYym7L9ch+tWdDJBvKVQwpfAkxZiJaSc=";
  };

  vendorHash = "sha256-G8eujeYLSlQ95hNLspAlWSj7MSB/eyg4iD2pp3kSupQ=";

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

  passthru.updateScript = [
    ../peertube-plugin-akismet/update.sh
    (unstableGitUpdater { tagPrefix = "v"; })
  ];

  meta = {
    homepage = "https://git.taler.net/taldir.git";
    description = "Directory service to resolve wallet mailboxes by messenger addresses.";
    license = lib.licenses.agpl3Plus;
  };
})
