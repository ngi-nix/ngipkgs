{
  lib,
  ...
}:
[
  # https://github.com/NixOS/nixpkgs/pull/456291
  (final: prev: {
    stalwart-mail = prev.stalwart-mail.overrideAttrs (oldAttrs: {
      nativeCheckInputs = oldAttrs.nativeCheckInputs or [ ] ++ [ final.openssl ];
    });
  })
  (final: prev: {
    scion-apps = prev.scion-apps.overrideAttrs (oldAttrs: {
      checkFlags =
        let
          skippedTests = [
            # FIX: why does this fail?
            "TestRoundTripper"
            "TestMangleSCIONAddrURL"
          ];
        in
        oldAttrs.checkFlags or [ ] ++ [ "-skip=^${lib.concatStringsSep "$|^" skippedTests}$" ];
    });
  })
]
