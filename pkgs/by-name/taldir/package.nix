{
  lib,
  fetchgit,
  recutils,
  buildGoModule,
  _experimental-update-script-combinators,
  unstableGitUpdater,
  nix-update-script,
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

  # Currently, `nix-update-script` can only get latest version from:
  # codeberg/crates.io/gitea/github/gitlab/pypi/savannah/sourcehut/rubygems/npm
  passthru.updateScript = _experimental-update-script-combinators.sequence [
    (unstableGitUpdater { tagPrefix = "v"; }) # update version + source
    (nix-update-script { extraArgs = [ "--version=skip" ]; }) # update deps
  ];

  meta = {
    homepage = "https://git.taler.net/taldir.git";
    description = "Directory service to resolve wallet mailboxes by messenger addresses.";
    license = lib.licenses.agpl3Plus;
  };
})
