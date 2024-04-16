{
  rustPlatform,
  fetchFromGitHub,
}: let
  src = fetchFromGitHub {
    owner = "mCaptcha";
    repo = "cache";
    rev = "67d6c701baa804849abc53a78422a6da01358487";
    # NOTE: Avoiding this typo fix (which caused a bug in libmcaptcha)
    # https://github.com/mCaptcha/cache/commit/f30bc54e6374cf5fad07af8f3d38bbe5fbbb4b20
    # until this is merged https://github.com/mCaptcha/libmcaptcha/pull/12
    sha256 = "sha256-whRLgYkoBoVQiZwrmwBwqgHzPqqXC6g3na3YrH4/xVo=";
  };
in
  rustPlatform.buildRustPackage {
    inherit src;
    pname = "cache";
    version = "unstable-2023-03-08";

    cargoLock = {
      lockFile = ./Cargo.lock;
      outputHashes = {
        "libmcaptcha-0.1.4" = "sha256-KwFT0Px5ZQGa26fjkiaT8lKc8ASVdfL/67E0hnaHl7I=";
      };
    };

    nativeBuildInputs = [rustPlatform.bindgenHook];

    checkPhase = ''
      runHook preCheck

      cargo test --all --all-features --no-fail-fast

      runHook postCheck
    '';
  }
