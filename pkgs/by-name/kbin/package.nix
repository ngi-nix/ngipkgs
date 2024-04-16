{
  lib,
  runCommand,
  kbin-frontend,
  kbin-backend,
  nixosTests,
}:
runCommand "kbin" {
  version = "0.0.1";
  passthru =
    kbin-backend.passthru
    // {
      tests = {
        inherit (nixosTests.Kbin) kbin;
      };
    };
  meta = {
    license = lib.licenses.agpl3Only;
    homepage = "https://kbin.pub/";
    description = "/kbin is a modular, decentralized content aggregator and microblogging platform running on the Fediverse network.";
  };
} ''
  # As of 2023-10-09, there is no way to just symlink
  # backend and frontend (using `lndir`):
  #
  #    lndir -silent ${kbin-backend}/share/php/kbin $out
  #    mkdir $out/public/build
  #    lndir -silent ${kbin-frontend} $out/public/build
  #
  # The backend will look up the frontend in its own
  # store path, where it will not find it and error.
  # A solution would be to use `builtins.outputOf` in
  # the backend derivation and link `public/build` to
  # the output path of the frontend via `builtins.outputOf`,
  # see <https://nixos.org/manual/nix/stable/language/builtins#builtins-outputOf>.
  # However, this requires the experimental feature
  # 'dynamic-derivations'.

  cp -r ${kbin-backend}/share/php/kbin $out
  chmod u+wx $out/public
  mkdir $out/public/build
  cp -r ${kbin-frontend}/* $out/public/build
''
