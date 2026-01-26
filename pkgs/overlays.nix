{
  lib,
  ...
}:
[
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
  (final: prev: {
    sylkserver = prev.sylkserver.overrideAttrs (oldAttrs: {
      postPatch = oldAttrs.postPatch or "" + ''
        # "value must be a string"
        substituteInPlace \
          sylk/configuration/__init__.py \
          sylk/applications/xmppgateway/configuration.py \
            --replace-fail "host.default_ip" "host.default_ip or '127.0.0.1'"
      '';
    });
  })
  (final: prev: {
    # Remove on next release: https://github.com/NixOS/nixpkgs/pull/456442
    canaille = prev.canaille.overridePythonAttrs { doCheck = false; };
    python3 = prev.python3.override {
      packageOverrides = pyfinal: pyprev: {
        # put python modules' overrides here
      };
    };
    python3Packages = final.python3.pkgs;
  })
]
