{#Contributor_Why_to_maintain_updatability_of_a_package_using_a_Fixed-Output_Derivation_by_leaking_version_into_name}
# Why to maintain updatability of a package by leaking `version` into the `name` of a Fixed-Output Derivation?

{#Contributor_Why_to_maintain_updatability_of_a_package_using_a_Fixed-Output_Derivation_by_leaking_version_into_name_Without_leaking_version}
## Without leaking `version`
Building with `version = "4.11.0"`:
nix records that `sha256-YNd96qFJ8SHBgDEEsoNps888myGZdELbbuYCae9pW3M=`
outputs `/nix/store/l6q51hmj4nx2wkscp0gi96g1dp1f2w7a-source`.
```console
$ nix -L build --no-link --print-out-paths --impure --expr \
  'let pkgs = import (builtins.getFlake "flake:nixpkgs") {}; version="4.11.0"; in pkgs.fetchFromGitHub { owner = "opencv"; repo = "opencv_contrib"; tag = version; hash = "sha256-YNd96qFJ8SHBgDEEsoNps888myGZdELbbuYCae9pW3M="; }'
/nix/store/l6q51hmj4nx2wkscp0gi96g1dp1f2w7a-source
```

Bumping to `version = "4.12.0"`:
building wrongly outputs the same path:
```console
$ nix -L build --no-link --print-out-paths --impure --expr \
  'let pkgs = import (builtins.getFlake "flake:nixpkgs") {}; version="4.12.0"; in pkgs.fetchFromGitHub { owner = "opencv"; repo = "opencv_contrib"; tag = version; hash = "sha256-YNd96qFJ8SHBgDEEsoNps888myGZdELbbuYCae9pW3M="; }'
/nix/store/l6q51hmj4nx2wkscp0gi96g1dp1f2w7a-source
```

It does not help to delete the build result from the Nix store.
```console
$ nix-store --delete /nix/store/l6q51hmj4nx2wkscp0gi96g1dp1f2w7a-source
$ nix -L build --no-link --print-out-paths --impure --expr \
  'let pkgs = import (builtins.getFlake "flake:nixpkgs") {}; version="4.12.0"; in pkgs.fetchFromGitHub { owner = "opencv"; repo = "opencv_contrib"; tag = version; hash = "sha256-YNd96qFJ8SHBgDEEsoNps888myGZdELbbuYCae9pW3M="; }'
/nix/store/l6q51hmj4nx2wkscp0gi96g1dp1f2w7a-source
```

Nor does it help to use `--repair` and `--refresh`:
```console
$ nix -L build --repair --refresh --no-link --print-out-paths --impure --expr \
  'let pkgs = import (builtins.getFlake "flake:nixpkgs") {}; version="4.12.0"; in pkgs.fetchFromGitHub { owner = "opencv"; repo = "opencv_contrib"; tag = version; hash = "sha256-YNd96qFJ8SHBgDEEsoNps888myGZdELbbuYCae9pW3M="; }'
/nix/store/l6q51hmj4nx2wkscp0gi96g1dp1f2w7a-source
```

{#Contributor_Why_to_maintain_updatability_of_a_package_using_a_Fixed-Output_Derivation_by_leaking_version_into_name_With_leaking_version}
## With leaking `version`

When `version` is leaked into `name` the mismatching hash
is spotted when bumping `version` whatever is cached in the Nix store:

```console
$ nix -L build --no-link --print-out-paths --impure --expr \
  'let pkgs = import (builtins.getFlake "flake:nixpkgs") {}; version="4.11.0"; in pkgs.fetchFromGitHub { owner = "opencv"; repo = "opencv_contrib"; tag = version; hash = "sha256-YNd96qFJ8SHBgDEEsoNps888myGZdELbbuYCae9pW3M="; name = "opencv_contrib-${version}"; }'
/nix/store/rpq9x7r1mwjfqcyk5qf77cqr2vpgzwrr-opencv_contrib-4.11.0

$ nix -L build --no-link --print-out-paths --impure --expr \
  'let pkgs = import (builtins.getFlake "flake:nixpkgs") {}; version="4.12.0"; in pkgs.fetchFromGitHub { owner = "opencv"; repo = "opencv_contrib"; tag = version; hash = "sha256-YNd96qFJ8SHBgDEEsoNps888myGZdELbbuYCae9pW3M="; name = "opencv_contrib-${version}"; }'
error: hash mismatch in fixed-output derivation '/nix/store/10mdh0k9iln5f7ddk19r1qv39zrg6s3i-opencv_contrib-4.12.0.drv':
         specified: sha256-YNd96qFJ8SHBgDEEsoNps888myGZdELbbuYCae9pW3M=
            got:    sha256-3tbscRFryjCynIqh0OWec8CUjXTeIDxOGJkHTK2aIao=
```
