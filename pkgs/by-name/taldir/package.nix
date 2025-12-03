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
  version = "1.0.5-unstable-2025-11-07";

  src = fetchgit {
    url = "https://git-www.taler.net/taldir.git";
    rev = "dc4fbabd435b108a78d0cc445bb4225f92eb0e22";
    hash = "sha256-WgkOZ+FWN6NLL8DR/wcscKJ0h2uOs+pi3BbT8t3/XE4=";
    # Update submodules to use `git-www.taler.net` since `git.gnunet.org` no
    # longer hosts source code.
    leaveDotGit = true;
    fetchSubmodules = false;
    postFetch = ''
      pushd $out
        git reset --hard HEAD

        substituteInPlace .gitmodules \
          --replace-fail "git.gnunet.org" "git-www.taler.net"

        git submodule update --init --recursive

        rm -rf .git
      popd
    '';
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
