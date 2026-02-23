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
  version = "1.3.3-unstable-2026-02-17";

  src = fetchgit {
    url = "https://git-www.taler.net/taldir.git";
    rev = "228a58526dcdb6863021e10109dafb411b5726d4";
    hash = "sha256-f/50jnf7h0SzHnRVbp7vbwRpMsMb6wqb1P7m+kDRrPY=";
  };

  vendorHash = "sha256-eZFE/hWQPG88lZT9KM/j2B0uoWvWQaPoMNcBKf5jWj8=";

  nativeBuildInputs = [
    recutils
  ];

  # From contrib/gana_update.sh
  preBuild = ''
    TALDIR_SRC_ROOT="$PWD"
    GANA_TMP=`mktemp -d`

    cleanup() { rm -rf "$GANA_TMP" ; }
    trap cleanup EXIT

    pushd $GANA_TMP || exit 1
    cp -R ${finalAttrs.passthru.gana}/. .
    chmod -R u+w .
    make -C gnu-taler-error-codes taler_error_codes.go  >/dev/null && \
      cp gnu-taler-error-codes/taler_error_codes.go $TALDIR_SRC_ROOT/internal/gana/ || exit 1
    popd

    cleanup
  '';

  subPackages = [
    "cmd/taldir-cli"
    "cmd/taldir-server"
  ];

  # dial error (dial tcp [::1]:5432: connect: connection refused)
  doCheck = false;

  passthru.gana = fetchgit {
    url = "https://git-www.taler.net/gana.git";
    rev = "eb54e871ae23f3f8ca7ce46c314fd995c930511e";
    hash = "sha256-hUTo/h5fT/40PdzvxHl8tX8oPDdWHC1gw3yIBbrCxuI=";
  };

  # Currently, `nix-update-script` can only get latest version from:
  # codeberg/crates.io/gitea/github/gitlab/pypi/savannah/sourcehut/rubygems/npm
  passthru.updateScript = _experimental-update-script-combinators.sequence [
    (unstableGitUpdater { tagPrefix = "v"; }) # version + source
    (nix-update-script { extraArgs = [ "--version=skip" ]; }) # Go deps
  ];

  meta = {
    homepage = "https://git.taler.net/taldir.git";
    description = "Directory service to resolve wallet mailboxes by messenger addresses.";
    license = lib.licenses.agpl3Plus;
  };
})
