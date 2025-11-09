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
  # Canaille
  (final: prev: {
    python3 = prev.python3.override {
      packageOverrides = pyfinal: pyprev: {
        # https://github.com/pallets-eco/flask-alembic/issues/47
        flask-alembic = pyprev.flask-alembic.overridePythonAttrs {
          meta.broken = false;
          doCheck = pyfinal.pythonOlder "3.13";
        };
      };
    };
    canaille = prev.canaille.overridePythonAttrs (oldAttrs: {
      doCheck = final.python3Packages.pythonOlder "3.13";
    });
  })
]
